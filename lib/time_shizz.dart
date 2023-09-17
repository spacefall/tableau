import "package:timetable/timetable.dart";

/// Punta al lunedì della settimana corrente
final DateTime weekStart = DateTime.now()
    .subtract(Duration(days: DateTime.now().weekday - DateTime.monday))
    .atStartOfDay
    .copyWith(isUtc: true);

/// Punta al sabato della settimana corrente
final DateTime weekEnd = weekStart.add(const Duration(days: 5));

/// Punta al lunedì (se il giorno è lunedì, martedì, mercoledì o domenica) o il giovedì (nel resto dei giorni) della settimana corrente
final DateTime weekHalf = switch (DateTime.now().weekday) {
  DateTime.thursday || DateTime.friday || DateTime.saturday => weekStart.add(
      const Duration(days: 3),
    ),
  _ => weekStart,
};
