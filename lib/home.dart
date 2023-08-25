import "package:flutter/material.dart";
import "package:tableau/event_generator.dart";
import "package:tableau/get_timetable.dart";
import "package:tableau/time_shizz.dart";
import "package:timetable/timetable.dart";

class TableauHome extends StatefulWidget {
  const TableauHome({super.key, required this.title});

  final String title;

  @override
  State<TableauHome> createState() => _TableauHomeState();
}

class _TableauHomeState extends State<TableauHome> {
  // Indica se sta usando la vista a 6 giorni o a 3
  bool isExtendedView = false;
  // Questo DateController viene modificato a runtime, per rendere l'app più reattiva
  final _dateController = DateController();

  final _timeController = TimeController(
    minDuration: const Duration(hours: 2), // Max zoom
    maxRange: TimeRange(
      const Duration(hours: 7),
      const Duration(hours: 15),
    ), // Max display
  );

  late Future<List<BasicEvent>> _timetablePage;

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
    _timetablePage = getHtmlBody(
      ttUrl,
    ).then(
      (value) => createEventsFromMap(
        parseTimetable(value),
        Theme.of(context).colorScheme.inversePrimary,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeWindow = MediaQuery.of(context).size.width >= 800;

    // Modifica il dateController, facendo vedere 6 giorni se lo schermo è abbastanza largo
    if (isLargeWindow && !isExtendedView) {
      isExtendedView = true;
      _dateController.visibleRange = VisibleDateRange.days(
        6,
        minDate: weekStart,
        maxDate: weekEnd,
      );
      _dateController.jumpTo(weekStart);
      // Altrimenti ne fa vedere solo 3 scrollabili e si sposta alla metà della settimana corrente più appropriata
    } else if (!isLargeWindow && isExtendedView) {
      isExtendedView = false;
      _dateController.visibleRange = VisibleDateRange.days(
        3,
        swipeRange: 3,
        minDate: weekStart,
        maxDate: weekEnd,
      );
      _dateController.jumpTo(weekHalf);
    }

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // Carica _timetablePage (la tabella di eventi che estrapola dall'html) in modo asincrono
      // e quando è pronto sostituisce il widget di caricamento con la tabella
      body: FutureBuilder(
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
              child: RecurringMultiDateTimetable<BasicEvent>(),
            );
            // FIXME: Se non è tutto ok ed il futuro restituisce un errore
            /* {
              
            } */
            // Mentre si sta caricando l'orario
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
