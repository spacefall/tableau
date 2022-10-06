import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<List<List>> getNewTimetable(String url) async {
  final htmlResponse = await http.Client()
      .get(Uri.parse("https://corsio-test.herokuapp.com/?$url"));

  if (htmlResponse.statusCode == 200) {
    final timetablehtml = parse(htmlResponse.body);
    final coord = timetablehtml
        .getElementsByTagName("font")[2]
        .innerHtml
        .replaceAll("\n", "")
        .replaceAll("Coord.&nbsp;", "Coordinatore: ")
        .replaceAll("&nbsp;", "Nessuno");
    final tablev2 = timetablehtml
        .getElementsByTagName("table")[1]
        .getElementsByTagName("table");

    List<String> urlSplitLayer1 = url.split("/");
    List<String> urlSplitLayer2 =
        urlSplitLayer1[urlSplitLayer1.length - 3].split("_");
    List<String> urlSplitLayer3 =
        urlSplitLayer2[urlSplitLayer2.length - 1].split("-");

    urlSplitLayer2[urlSplitLayer2.length - 1] = "%DATE%";
    urlSplitLayer1[urlSplitLayer1.length - 3] = urlSplitLayer2.join("_");

    int idxv2 = 0;
    List<List> filteredTimetablev2 = [
      [
        [],
      ], // subject
      [
        [],
      ], // prof.
      [
        [],
      ], // classroom
      [
        coord, //class coordinator
        urlSplitLayer3[0], //day
        urlSplitLayer3[1], //month
        urlSplitLayer1.join("/"), //no date url
      ],
    ];
    for (int i = 0; i < tablev2.length; i++) {
      var xx = tablev2[i].getElementsByTagName("td");
      bool isLab = false;
      for (int ind = 0; ind < xx.length; ind++) {
        var td = xx[ind];
        if (ind == 0) {
          if (td.innerHtml.replaceAll("\n", "") == "") {
            filteredTimetablev2[0][idxv2].add("-");
            filteredTimetablev2[1][idxv2].add("-");
            filteredTimetablev2[2][idxv2].add("-");
            continue;
          }
          if (td.getElementsByTagName("font")[0].innerHtml.contains("<b>")) {
            idxv2++;
            filteredTimetablev2[0].add([]);
            filteredTimetablev2[1].add([]);
            filteredTimetablev2[2].add([]);
            continue;
          }

          if (td.getElementsByTagName("font")[0].innerHtml.contains("(lab.)")) {
            isLab = true;
          }

          filteredTimetablev2[0][idxv2].add(td
              .getElementsByTagName("font")[0]
              .innerHtml
              .replaceFirst(".", "",
                  td.getElementsByTagName("font")[0].innerHtml.length - 2)
              .replaceAll("\n", ""));
        } else if (ind == 1) {
          // ignore: dead_code
          if (isLab) {
            filteredTimetablev2[1][idxv2].add(
                "${td.getElementsByTagName("b")[0].innerHtml} | ${xx[ind + 1].getElementsByTagName("b")[0].innerHtml}"
                    .replaceAll("\n", ""));
          } else {
            filteredTimetablev2[1][idxv2].add(
                td.getElementsByTagName("b")[0].innerHtml.replaceAll("\n", ""));
          }
          if (xx.length < 3) {
            filteredTimetablev2[2][idxv2].add("-");
          }
        } else if (isLab && xx.length < 4) {
          filteredTimetablev2[2][idxv2].add("-");
        } else if (ind == 2) {
          // ignore: dead_code
          if (isLab) {
            filteredTimetablev2[2][idxv2].add(xx[ind + 1]
                .getElementsByTagName("font")[0]
                .innerHtml
                .replaceAll("\n", ""));
          } else {
            filteredTimetablev2[2][idxv2].add(td
                .getElementsByTagName("font")[0]
                .innerHtml
                .replaceAll("\n", ""));
          }
        }
      }
    }
    return filteredTimetablev2;
  } else {
    return [
      [
        ["nodata"]
      ]
    ];
  }
}
