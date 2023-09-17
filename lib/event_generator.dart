import "package:flutter/material.dart";
import "package:tableau/lessontimes.dart";
import "package:tableau/table_classes.dart";
import "package:tableau/time_shizz.dart";
import "package:timetable/timetable.dart";

List<BasicEvent> createEventsFromTimetable(
  Timetable tt,
  Color bgColor,
  bool alwaysUseStandardTime,
) {
  final List<BasicEvent> eventList = [];

  tt.table.forEach((weekday, materie) {
    final Map<int, Map<String, List<int>>> orarioMateria = alwaysUseStandardTime
        ? orariLezioni["normale"]!
        : switch (weekday) {
            1 || 4 => orariLezioni["ridotto"]!,
            _ => orariLezioni["normale"]!,
          };

    eventList.add(
      BasicEvent(
        id: 99 * 10 + weekday,
        title: "Intervallo",
        backgroundColor: Colors.red,
        start: weekStart.add(
          Duration(
            days: weekday,
            hours: orarioMateria[99]!["inizio"]![0],
            minutes: orarioMateria[99]!["inizio"]![1],
          ),
        ),
        end: weekStart.add(
          Duration(
            days: weekday,
            hours: orarioMateria[99]!["fine"]![0],
            minutes: orarioMateria[99]!["fine"]![1],
          ),
        ),
      ),
    );

    for (final (index, slot) in materie.indexed) {
      if (slot.materia.isEmpty) continue;

      eventList.add(
        BasicEvent(
          id: weekday * 10 + index,
          title: eventTitleGenerator(
            materia: slot.materia,
            prof0: slot.prof0!,
            prof1: slot.prof1,
            classe: slot.classe,
          ),
          backgroundColor: bgColor,
          start: weekStart.add(
            Duration(
              days: weekday,
              hours: orarioMateria[index]!["inizio"]![0],
              minutes: orarioMateria[index]!["inizio"]![1],
            ),
          ),
          end: weekStart.add(
            Duration(
              days: weekday,
              hours: orarioMateria[index]!["fine"]![0],
              minutes: orarioMateria[index]!["fine"]![1],
            ),
          ),
        ),
      );
    }
  });
  return eventList;
}

String eventTitleGenerator({
  required String materia,
  required String prof0,
  required String? prof1,
  required String? classe,
}) {
  String title = "$materia\n$prof0\n";
  if (prof1 != null) title += "$prof1\n";
  return title += classe ?? "Classe non specificata";
}
