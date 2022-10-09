import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  final Uri uri = Uri.parse(url);
  if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {
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
