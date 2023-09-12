import "dart:convert";

import "package:html/dom.dart";
import "package:html/parser.dart" as parser;
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "package:tableau/table_classes.dart";

// TODO: cambia nome
Future<Timetable> prepareEvents(String url) async {
  // TODO: aggiungi modo per controllare che url sia uguale a quello salvato altrimenti
  // se viene cambiato l'url la tabella rimane la stessa
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  //final String? table = prefs.getString("table");
  const String? table = null;
  if (table == null) {
    final Timetable newTable = parseTimetable(await getHtmlBody(url));
    prefs.setString("table", jsonEncode(newTable));
    return newTable;
  } else {
    final Timetable parsedSavedTable = Timetable.fromJson(
      jsonDecode(table) as Map<String, dynamic>,
    );
    return parsedSavedTable;
  }
}

/// Restituisce il body dell'html dall'url richiesto
Future<String> getHtmlBody(String url) async {
  try {
    final http.Response res = await http.get(
      Uri.parse(url),
    );
    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw Exception("response status code is ${res.statusCode}");
    }
  } catch (e) {
    throw Exception(e);
  }
}

/// Prende il body dell'html della tabella e restituisce un Map
Timetable parseTimetable(String html) {
  // Inizializza tabella
  final Timetable timetableMap = Timetable();

  // Parse e recupera le celle
  final Document document = parser.parse(html);
  final List<Element> cells = document.querySelectorAll("td:only-child");

  final int firstweekday = switch (cells[1].text.trim()) {
    "lunedÃ¬" => 0,
    "martedÃ¬" => 1,
    "mercoledÃ¬" => 2,
    "giovedÃ¬" => 3,
    "venerdÃ¬" => 4,
    "sabato" => 5,
    _ => throw Exception("day out of range")
  };

  // Variabili per comodità
  int weekday =
      firstweekday; // Indica il giorno della settimana in cui scrivere ttSlot
  int step =
      0; // Indica qual è il prossimo step (ovvero quale parte viene salvata (materia/prof/classe))
  //bool isLab = false; // Indica se è possibile che la materia è di laboratorio (e quindi ha 2 professori)
  Timeslot? ttSlot; // Tiene il timeslot che viene costruito nel loop

  for (final (index, element) in cells.indexed) {
    if (element.attributes.containsKey("align") || index < (7 - firstweekday)) {
      continue;
    }

    final String cellText = element.text.replaceAll("\n", "");
    switch (step) {
      //Materia
      case 0:
        ttSlot = Timeslot(materia: cellText);

        //isLab = cellText.endsWith(". ");

        cellText.isNotEmpty
            ? step++
            : weekday == 5
                ? weekday = firstweekday
                : weekday++;

      // Professori
      case 1:
        //isLab ? ttSlot!.prof1 = cellText : ttSlot!.prof0 = cellText;

/*         final bool isNextClass = cells.length != index + 1
            ? cells[index + 1].querySelector("font")?.attributes["size"] == "1"
            : false; */
        final bool isNextClass = cells.length != index + 1 &&
            cells[index + 1].querySelector("font")?.attributes["size"] == "1";

        final bool isNextProf = cells.length != index + 1 &&
            cells[index + 1].text == cells[index + 1].text.toUpperCase();

        if (isNextClass) {
          ttSlot!.prof0 = cellText;
          step++;
        } else {
          if (isNextProf) {
            ttSlot!.prof1 = cellText;
          } else {
            step = 0;
            timetableMap.add(weekday, ttSlot!);
            weekday == 5 ? weekday = firstweekday : weekday++;
          }
        }
      /* switch ((isLab, isNextClass)) {
          case (true, true):
          case (false, true): // || (true, true):
            ttSlot!.prof0 = cellText;
            step++;
          case (true, false):
            ttSlot!.prof1 = cellText;
            isLab = false;
          case (false, false):
            step = 0;
            timetableMap.add(weekday, ttSlot!);
            weekday == 5 ? weekday = firstweekday : weekday++;
        } */

      // Classe
      case 2:
        ttSlot!.classe = cellText;
        step = 0;
        timetableMap.add(weekday, ttSlot);
        weekday == 5 ? weekday = firstweekday : weekday++;
      default:
        throw Exception("Step out of range");
    }
  }
  return timetableMap;
}
