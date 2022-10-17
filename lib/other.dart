import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiffy/jiffy.dart';

String translateError(String error) {
  switch (error) {
    case "connectionerr":
      {
        return "C'è stato un errore di connessione, riprova più tardi. ($error)";
      }

    case "probably404":
      {
        return "Generalmente non dovresti vedere questo, ma l'ultimo orario caricato.\nProva a controllare il link che hai impostato e riprova. ($error)";
      }

    case "firsttime":
      {
        return """
Sembra che sia la prima volta che apri questa applicazione.

Per iniziare vai sul sito della scuola e vai su:
Orario delle lezioni > Orario singole classi > la tua classe.

Copia il link ed incollalo in:
Impostazioni (l'ingranaggio in alto a sinistra) > Link orario scuola.
""";
      }

    default:
      {
        return "Evidentemente hai rotto tutto, così tanto che pure l'errore non è riconosciuto. Reinstalla l'app e riprova. ($error)";
      }
  }
}

// Funzione per aprire comodamente un link
void openWebsite(String url, BuildContext context) async {
  final uri = Uri.parse(url);
  if (await DataConnectionChecker().hasConnection) {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Impossibile aprire sito"),
      ));
    }
  } else {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Non sei connesso ad Internet"),
    ));
  }
}

// Decide se il link va cambiato
bool shouldUpdateLink(SharedPreferences prefs) {
  final lastCheckWeek = prefs.getInt('lastCheckWeek') ?? 0;
  final thisWeek = Jiffy().week;
  print("lstchkwk: $lastCheckWeek");
  print("thswk: $thisWeek");
  print("isLCW == tW? ${lastCheckWeek != thisWeek}");
  print("isLCW == tW+1? ${lastCheckWeek != (thisWeek + 1)}");
  print(
      "isLCW == tW/tW+1? ${lastCheckWeek != thisWeek || lastCheckWeek != thisWeek + 1}");
  print("day: ${Jiffy().day}");
  if (lastCheckWeek != thisWeek && lastCheckWeek != thisWeek + 1) {
    // Se il link è di un'altra settimana va cambiato
    return true;
  } else {
    if (Jiffy().day == 7 && lastCheckWeek != thisWeek + 1) {
      print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaa");
      // Se non è di un'altra settimana ma è domenica va cambiato
      return true;
    } else {
      // Se il link è di questa settimana e non è domanica non va cambiato
      return false;
    }
  }
}
