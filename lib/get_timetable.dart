import "package:html/dom.dart";
import "package:html/parser.dart" as parser;
import "package:http/http.dart" as http;

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

Map<int, Map<int, Map<String, String>>> parseTimetable(String html) {
  final Map<int, Map<int, Map<String, String>>> timetableMap = {
    0: {},
    1: {},
    2: {},
    3: {},
    4: {},
    5: {},
  };

  final Document document = parser.parse(html);
  final List<Element> cells = document.querySelectorAll("td:only-child");

  int weekday = 0;
  int step = 0;
  bool isLab = false;

  for (final (index, element) in cells.indexed) {
    if (element.attributes.containsKey("align") || index < 7) continue;

    final String cellText = element.text.replaceAll("\n", "");
    final Map<int, Map<String, String>> weekdayMap = timetableMap[weekday]!;

    switch (step) {
      //Materia
      case 0:
        if (cellText.contains("(lab.)")) isLab = true;
        weekdayMap.addAll(
          {
            weekdayMap.length: {
              "materia": cellText,
            },
          },
        );
        //step++;
        cellText.isNotEmpty
            ? step++
            : weekday == 5
                ? weekday = 0
                : weekday++;

      // Professori
      case 1:
        //final Map<String, String> profMap = isLab ? {"prof1": cellText} : {"prof0": cellText}
        final String profN = isLab ? "prof1" : "prof0";
        weekdayMap[weekdayMap.length - 1]!.addAll(
          {
            profN: cellText,
          },
        );

        if (isLab) {
          isLab = false;
        } else if (cells.length == index + 1 ||
            cells[index + 1].querySelector("font")?.attributes["size"] != "1") {
          step = 0;
          weekday == 5 ? weekday = 0 : weekday++;
        } else {
          step++;
        }

      // Classe
      case 2:
        weekdayMap[weekdayMap.length - 1]!.addAll(
          {
            "classe": cellText,
          },
        );
        step = 0;
        weekday == 5 ? weekday = 0 : weekday++;

      default:
        throw Exception("Step out of range");
    }
  }
  return timetableMap;
}
