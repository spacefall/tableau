import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Legge la Tabella oraria salvata da SharedPreferences e la restituisce
// Però grande dubbione se sarebbe meglio fare una nuova istanza di SharedPreferences o tenere quella iniziale, come è adesso
Future<List<List>> readTTFromLocal(SharedPreferences prefs) async {
  final int? listIndexes = prefs.getInt('ttLength');
  final List<String>? chunk3 = prefs.getStringList('ttChunk3');

  // I dati non sono salvati o qualcosa di veramente bizzarro sta succedendo
  if (listIndexes == null || chunk3 == null) {
    return [
      [
        "nodata",
        "Hai probabilmente rotto proprio tutto ;P\nMa seriamente, non dovresti vedere questo, "
            /*a meno che tu non stia leggendo pure questo commento*/
            "prova a cancellare i dati e riprovare."
      ],
    ];
  }

  // Creare la variabile ora, evita di crearla per niente
  List<List> tt = [
    [], // Materia
    [], // Prof.
    [], // Classe
    [], // Dati vari come coordinatore di classe, 'template' link, data dell'orario ecc.
  ];

  // Siccome SharedPreferences supporta solo List<String> (in termini di liste) questo itera per ogni pezzo (aka ttChunk) e lo aggiunge a tt
  for (int idx = 0; idx <= 2; idx++) {
    for (int i = 0; i < listIndexes; i++) {
      tt[idx].add(prefs.getStringList('ttChunk$idx-$i'));
    }
  }

  tt[3] = chunk3;

  return tt;
}

// Scrive la tabella oraria con SharedPreferences
void writeTTtoLocal(List<List> tt, SharedPreferences prefs) async {
  // Stesso concetto dela funzione sopra: Siccome SharedPreferences supporta solo List<String> (in termini di liste) questo itera per ogni pezzo e lo aggiunge a SharedPreferences
  for (int idx = 0; idx <= 2; idx++) {
    for (int i = 0; i < tt[0].length; i++) {
      await prefs.setStringList('ttChunk$idx-$i', tt[idx][i].cast<String>());
    }
  }

  await prefs.setStringList('ttChunk3', tt[3].cast<String>());
  await prefs.setInt('ttLength', tt[0].length);
}

// Cancella tutti i dati salvati e "chiude" l'app
void resetToFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}
