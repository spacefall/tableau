import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:recase/recase.dart';

// Esegue il parsing dal sito maggiko di Spaggiari, molte altre scuole usano dei pdf messi sullo stesso server quindi non è proprio universale
// Anche perchè Einaudi-Scarpa usa Untis 2019 e carica l'html sui server di Spaggiari ed entrame le sedi usano 2 formati diversi per il link
// Quindi altre scuole che hanno più o meno lo stesso setup vanno comunque inserite manualmente in getExtraData per funzionare completamente
Future<List<List>> getNewTimetable(String url) async {
  print("Caricando nuovo orario");
  print(kIsWeb);
  late final http.Response htmlResponse;
  if (await DataConnectionChecker().hasConnection) {
    if (kIsWeb) {
      // Uso un bellissimo proxy CORS perchè i server Spaggiari lo blocca, inoltre giusto per informazione gli orari sono pubblici
      // Quindi se un'altra scuola usa un setup simile ma richiede password, non lo aggiungo perchè anche se corsproxy.io dice che rispetta il GDPR e non tiene log
      // Fidarsi è bene, non fidarsi è meglio // <- mettere altre due slash qui non ha alcuna funzione ma mi piaceva
      htmlResponse =
          await http.Client().get(Uri.parse("https://corsproxy.io/?$url"));
    } else {
      // Evitiamo il proxy su app, così è teroicamente più stabile
      htmlResponse = await http.Client().get(Uri.parse(url));
    }
  } else {
    return [
      ["nodata", "connecterr"]
    ];
  }

  if (htmlResponse.statusCode == 200) {
    final timetableHTML = parse(htmlResponse.body);
    // Dopo il parsing qui sopra, filtra le tabelle nelle tabelle per avere solo materie, classi e prof; dato che ci sono un sacco tabelle su quel sito
    final tables = timetableHTML
        .getElementsByTagName("table")[1]
        .getElementsByTagName("table");

    var tablesIndex = 0; // Serve a capire a che punto è arrivato il loop
    List<List> finalTimetable = [
      [
        [], // Materia
      ],
      [
        [], // Professore
      ],
      [
        [], // Classe assegnata
      ],
      getExtraData(timetableHTML, url), // Dati Extra
    ];

    // Per ogni tabella, separa il tag td (quindi il testo contenuto in un tag <font> o <font><b>
    for (int i = 0; i < tables.length; i++) {
      final tdTags = tables[i].getElementsByTagName("td");
      late final bool
          isLab; // final è più "ottimizzato" di var in questo caso? Cioè viene resettato quando arriva il loop quindi non cambia niente?
      for (int idx = 0; idx < tdTags.length; idx++) {
        final td = tdTags[idx];
        // Qui comincia la conversione in liste
        // idx == 0 è sempre una materia
        if (idx == 0) {
          // Se vuoto mette una linea su tutte le liste, inoltre sono tutti in if diversi invece else if perchè mi sembrava più leggibile dato che guardano tutti cose diverse
          // Questo è in caso di ore mancanti, es. solo il martedì ed il venerdì hanno 6 (da quest'anno anche mercoledì o giovedì per quelli del tecnologico)
          // Se la materia è vuota, aggiungi un trattino su tutte le liste e ricomincia il loop
          if (td.innerHtml.replaceAll("\n", "") == "") {
            finalTimetable[0][tablesIndex].add("-");
            finalTimetable[1][tablesIndex].add("-");
            finalTimetable[2][tablesIndex].add("-");
            continue;
          }
          final String tdText = td.getElementsByTagName("font")[0].innerHtml;
          // Se invece il testo è in grassetto (<b>) è il numero dell'ora quindi crea una nuova lista e ricomincia il loop
          if (tdText.contains("<b>")) {
            tablesIndex++;
            finalTimetable[0].add([]);
            finalTimetable[1].add([]);
            finalTimetable[2].add([]);
            continue;
          }

          // Se la materia contiene (lab.) è una materia di laboratorio e quindi ha 2 prof in 2 tabelle diverse
          if (tdText.contains("(lab.)")) {
            isLab = true;
          } else {
            isLab = false;
          }

          // Prendi il testo dal tag <font> e aggiungilo nella lista
          finalTimetable[0][tablesIndex].add(tdText
              .replaceFirst(".", "", tdText.length - 2)
              .replaceAll("\n", ""));
        } else if (idx == 1) {
          // idx == 1 è sempre un prof (su 2 se è lab)
          final tdText = ReCase(td.getElementsByTagName("b")[0].innerHtml)
              .titleCase
              .replaceAll(
                  "\n", ""); // Usato per rendere il codice un po' più leggibile
          // Se la materia ha 2 prof (aka è lab) mette i 2 prof assieme, separati da |
          if (isLab) {
            finalTimetable[1][tablesIndex].add(
                "$tdText. | ${ReCase(tdTags[idx + 1].getElementsByTagName("b")[0].innerHtml).titleCase}."
                    .replaceAll("\n", ""));
          } else {
            finalTimetable[1][tablesIndex].add("$tdText.");
          }

          // Se non c'è una classe segnata non occupa una tabella e quindi non viene sengata nella lista, e quindi l'app crasha
          // Questo risolve il problema facendo il check durante il parsing del/lla/i prof
          if (tdTags.length < 3 || isLab && tdTags.length < 4) {
            finalTimetable[2][tablesIndex].add("-");
          }
        } else if (idx == 2) {
          // idx == 2 potrebbe essere la classe o un'altro prof (se lab)
          if (isLab) {
            finalTimetable[2][tablesIndex].add(tdTags[idx + 1]
                .getElementsByTagName("font")[0]
                .innerHtml
                .replaceAll("\n", ""));
          } else {
            finalTimetable[2][tablesIndex].add(td
                .getElementsByTagName("font")[0]
                .innerHtml
                .replaceAll("\n", ""));
          }
        }
      }
    }
    return finalTimetable;
  } else {
    return [
      ["nodata", "probably404"]
    ];
  }
}

// Riempe il 4 "spazio" della lista
List<String> getExtraData(Document parsedHtml, String url) {
  // Queste 3 variabili dividono il link fino alla data, brutto ma funziona
  var urlSplitLayer1 = url.split("/");
  var urlSplitLayer2 = urlSplitLayer1[urlSplitLayer1.length - 3].split("_");
  final date = urlSplitLayer2[urlSplitLayer2.length - 1].split("-");

  // Dopo aver assegnato la data, ricrea un link con %DATE% al posto della data, così può essere facilmente cambiata
  urlSplitLayer2[urlSplitLayer2.length - 1] = "%DATE%";
  urlSplitLayer1[urlSplitLayer1.length - 3] = urlSplitLayer2.join("_");

  // Prende il coordinatore di classe dalla tabella oraria
  final coord = ReCase(parsedHtml
          .getElementsByTagName("font")[2]
          .innerHtml
          .replaceAll("\n", "")
          .replaceAll("Coord.&nbsp;", "")
          .replaceAll("&nbsp;", "Nessuno"))
      .titleCase;

  return [
    coord, // Coordinatore di classe
    date[0], // Giorno
    date[1], // Mese
    urlSplitLayer1.join(
        "/"), // Url senza data, viene poi usato per aggiungere la nuova data, quindi è più pratico rispetto a fare i 3 split ogni volta
  ];
}
