import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:pref/pref.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:tableau/event_generator.dart";
import "package:tableau/get_timetable.dart";
import "package:tableau/settings.dart";
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
  late Future<List<BasicEvent>> _timetablePage;

  //
  late bool isTTInitialized;

  // Questo DateController viene modificato a runtime, per rendere l'app più reattiva
  final _dateController = DateController();

  final _timeController = TimeController(
    minDuration: const Duration(hours: 2), // Max zoom
    maxRange: TimeRange(
      const Duration(hours: 7),
      const Duration(hours: 15),
    ), // Max display
  );

  // TODO: refactor necessario tipo ieri
  void setTimetablePage(String ttUrl) {
    _timetablePage = prepareEvents(ttUrl).then(
      (value) => createEventsFromTimetable(
        value,
        Theme.of(context).colorScheme.inversePrimary,
        false,
      ),
    );
    isTTInitialized = true;
  }

  void setTTPageFromSettings() {
    setState(() {
      setTimetablePage(PrefService.of(context).get("ttUrl") as String);
    });
  }

  @override
  void dispose() {
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Imposta _timetablePage al posto di farlo nel futureBuilder
  // così non deve ricaricare la lista ogni volta che viene ricostruito il widget
  @override
  void initState() {
    isTTInitialized = widget.ttUrl != "";
    if (isTTInitialized) setTimetablePage(widget.ttUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  setTTPage: setTTPageFromSettings,
                ),
              ),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      // Carica _timetablePage (la tabella di eventi che estrapola dall'html) in modo asincrono
      // e quando è pronto sostituisce il widget di caricamento con la tabella
      body: isTTInitialized
          ? FutureBuilder(
              future: _timetablePage,
              builder: (context, snapshot) {
                // Se tutto ok ed stato caricato l'orario
                if (snapshot.connectionState == ConnectionState.done) {
                  return TimetableConfig<BasicEvent>(
                    dateController: _dateController,
                    timeController: _timeController,
                    eventProvider: eventProviderFromFixedList(
                      snapshot.data!,
                    ),
                    eventBuilder: (context, event) => BasicEventWidget(event),
                    theme: TimetableThemeData(
                      context,
                      dateEventsStyleProvider: (date) {
                        return DateEventsStyle(context, date,
                            enableStacking: true, stackedEventSpacing: 0);
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
