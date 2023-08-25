import "package:timetable/timetable.dart";

// TODO: cambia nome al file
// TODO: rendere le variabili funzioni? (così possono essere reinizializzate)

// Finali? pre inizializzate per comodità
/// Punta al lunedì della settimana corrente
final DateTime weekStart = DateTime.now()
    .subtract(Duration(days: DateTime.now().weekday - DateTime.monday))
    .atStartOfDay
    .copyWith(isUtc: true);

/// Punta al sabato della settimana corrente
final DateTime weekEnd = weekStart.add(const Duration(days: 5));

/// Punta al lunedì (se il giorno è lunedì, martedì, mercoledì o domenica) o il giovedì (nel resto dei giorni) della settimana corrente
final DateTime weekHalf = switch (DateTime.now().weekday) {
  // Mancherebbe la domenica ma ho realizzato che _ può sostiuire questa riga
  //DateTime.monday || DateTime.tuesday || DateTime.wednesday => weekStart,
  DateTime.thursday || DateTime.friday || DateTime.saturday => weekStart.add(
      const Duration(days: 3),
    ),
  _ => weekStart,
};

/*
DateTime getWeekStart() {
  return DateTime.now()
      .subtract(Duration(days: DateTime.now().weekday - DateTime.monday))
      .atStartOfDay
      .copyWith(isUtc: true);
}
 */
