import "package:flutter/material.dart";
import "package:tableau/table_classes.dart";
import "package:tableau/time_shizz.dart";
import "package:timetable/timetable.dart";

const Map<String, Map<int, Map<String, List<int>>>> orariLezioni = {
  "normale": {
    0: {
      "inizio": [08, 00],
      "fine": [09, 00],
    },
    1: {
      "inizio": [09, 00],
      "fine": [10, 00],
    },
    2: {
      "inizio": [10, 00],
      "fine": [11, 00],
    },
    3: {
      "inizio": [11, 15],
      "fine": [12, 15],
    },
    4: {
      "inizio": [12, 15],
      "fine": [13, 15],
    },
    5: {
      "inizio": [13, 15],
      "fine": [14, 15],
    },
  },
  "ridotto": {
    0: {
      "inizio": [07, 50],
      "fine": [08, 45],
    },
    1: {
      "inizio": [08, 45],
      "fine": [09, 40],
    },
    2: {
      "inizio": [09, 40],
      "fine": [10, 35],
    },
    3: {
      "inizio": [10, 50],
      "fine": [11, 40],
    },
    4: {
      "inizio": [11, 40],
      "fine": [12, 30],
    },
    5: {
      "inizio": [12, 30],
      "fine": [13, 20],
    },
  },
};
// TODO: cambia nome
List<BasicEvent> createEventsFromMap(
  Timetable tt,
  Color bgColor,
) {
  final List<BasicEvent> eventList = [];

  tt.table.forEach((weekday, materie) {
    final Map<int, Map<String, List<int>>> orarioMateria = switch (weekday) {
      1 || 4 => orariLezioni["ridotto"]!,
      _ => orariLezioni["normale"]!,
    };

    for (final (index, slot) in materie.indexed) {
      if (slot.materia.isEmpty) continue;

      eventList.add(
        BasicEvent(
          id: weekday * 10 + index,
          title: slot.materia,
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

  /* timetableMap.forEach((weekday, hourMap) {
    final Map<int, Map<String, List<int>>> orario = switch (weekday) {
      1 || 4 => orariLezioni["ridotto"]!,
      _ => orariLezioni["normale"]!,
    };
    hourMap.forEach((hour, value) {
      if (value["materia"]!.isNotEmpty) {
        eventList.add(
          BasicEvent(
            id: weekday * 10 + hour,
            title: value["materia"]!,
            backgroundColor: bgColor,
            start: weekStart.add(
              Duration(
                days: weekday,
                hours: orario[hour]!["inizio"]![0],
                minutes: orario[hour]!["inizio"]![1],
              ),
            ),
            end: weekStart.add(
              Duration(
                days: weekday,
                hours: orario[hour]!["fine"]![0],
                minutes: orario[hour]!["fine"]![1],
              ),
            ),
          ),
        );
      }
    });
  }); */
  return eventList;
}
