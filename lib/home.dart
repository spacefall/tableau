import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:pref/pref.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:tableau/event_generator.dart";
import "package:tableau/get_timetable.dart";
import "package:tableau/settings.dart";
import "package:tableau/table_classes.dart";
import "package:tableau/time_shizz.dart";
import "package:timetable/timetable.dart";

class TableauHome extends StatefulWidget {
  const TableauHome({super.key, required this.title, required this.ttUrl});

  final String title;
  final String ttUrl;

  @override
  State<TableauHome> createState() => _TableauHomeState();
}

class _TableauHomeState extends State<TableauHome> {
  // Indica se sta usando la vista a 6 giorni o a 3
  bool? isExtendedView;

  // Lista di eventi della tabella
  late Future<Timetable> _timetablePage;

  // Serve a determinare se esiste già un url per l'orario o no
  late bool isTTUrlSet;

  // Serve a determinare se la tabella è già stata creata (e quindi non deve essere rigenerata)
  bool isTTLoaded = false;

  // Tiene gli eventi, così possono essere rigenerati senza dover riaprire l'app
  List<BasicEvent> timetableEvents = [];

  // Questo DateController viene modificato a runtime, per rendere l'app più reattiva
  final _dateController = DateController();

  // Forza la visuale con uno zoom massimo di 2h e un range che va dalle 7 alle 15
  final _timeController = TimeController(
    minDuration: const Duration(hours: 2), // Max zoom
    maxRange: TimeRange(
      const Duration(hours: 7),
      const Duration(hours: 15),
    ), // Max display
  );

  void setTimetablePage(String ttUrl) {
    print("reloaded tt");
    _timetablePage = prepareEvents(
      ttUrl,
    );
    isTTUrlSet = true;
    isTTLoaded = true;
  }

  void refresh({bool deepRefresh = false}) {
    timetableEvents = [];
    if (deepRefresh) {
      isTTLoaded = false;
      isTTUrlSet = true;
    }
    setState(() {});
/*     setState(() {
      timetableEvents = [];

    }); */
  }

  // fa il dispose dei controller
  @override
  void dispose() {
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Imposta _timetablePage al posto di farlo nel futureBuilder così non deve ricaricare la lista ogni volta che viene ricostruito il widget
  @override
  void initState() {
    // TODO: capisco l'intento però si può fare di meglio
    isTTUrlSet = widget.ttUrl.isNotEmpty;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isTTUrlSet && timetableEvents.isEmpty && !isTTLoaded) {
      setTimetablePage(widget.ttUrl);
    }
    // Controlla se si deve usare la visualizzazione a 3 o 6 giorni
    final bool isLargeWindow = MediaQuery.of(context).size.width >= 800;
    isExtendedView ??= !isLargeWindow;

    // Modifica il dateController, facendo vedere 6 giorni se lo schermo è abbastanza largo
    if (isLargeWindow && !isExtendedView!) {
      isExtendedView = true;
      _dateController.visibleRange = VisibleDateRange.days(
        6,
        minDate: weekStart,
        maxDate: weekEnd,
      );
      _dateController.jumpTo(weekStart);
      // Altrimenti ne fa vedere solo 3 scrollabili e si sposta alla metà della settimana corrente più appropriata
    } else if (!isLargeWindow && isExtendedView!) {
      isExtendedView = false;
      _dateController.visibleRange = VisibleDateRange.days(
        3,
        swipeRange: 3,
        alignmentDate: weekStart,
        minDate: weekStart,
        maxDate: weekEnd,
      );
      _dateController.jumpTo(weekHalf);
    }

    // Il resto della schermata principale
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) => prefs.clear());
                PrefService.of(context).clear();
              },
              icon: const Icon(Icons.restore),
            ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TableauSettings(
                  refreshParent: refresh,
                ),
              ),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      // Carica _timetablePage (la tabella di eventi che estrapola dall'html) in modo asincrono
      // e quando è pronto sostituisce il widget di caricamento con la tabella
      body: isTTUrlSet
          ? FutureBuilder(
              future: _timetablePage,
              builder: (context, snapshot) {
                // Se tutto ok ed stato caricato l'orario
                if (snapshot.connectionState == ConnectionState.done) {
                  if (timetableEvents.isEmpty) {
                    timetableEvents = createEventsFromTimetable(
                      snapshot.data!,
                      Theme.of(context).colorScheme.inversePrimary,
                      Theme.of(context).colorScheme.primary,
                      PrefService.of(context).get("alwaysUseStandardTime")
                          as bool,
                    );
                    print("rebuilt list");
                  }
                  return TimetableConfig<BasicEvent>(
                    dateController: _dateController,
                    timeController: _timeController,
                    eventProvider: eventProviderFromFixedList(timetableEvents),
                    eventBuilder: (context, event) => BasicEventWidget(event),
                    theme: TimetableThemeData(
                      context,
                      dateEventsStyleProvider: (date) {
                        return DateEventsStyle(
                          context,
                          date,
                          enableStacking: true,
                          stackedEventSpacing: 0,
                        );
                      },
                    ),
                    child: RecurringMultiDateTimetable<BasicEvent>(),
                  );
                  // FIXME: Se non è tutto ok ed il futuro restituisce un errore
                  // Mentre si sta caricando l'orario
                } else {
                  return const LinearProgressIndicator();
                }
              },
            )
          : const Text("Inserisci url"),
    );
  }
}
