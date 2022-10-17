import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:validators/validators.dart';

import 'other.dart';
import 'main.dart';

class AppSettings extends StatefulWidget {
  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    // Tema per il testo delle categorie
    final catTheme = TextStyle(color: Theme.of(context).colorScheme.primary);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      // --Fonte--
      body: PrefPage(children: [
        PrefLabel(
          title: Text(
            'Fonte',
            style: catTheme,
          ),
        ),
        // Cambia link della tabella
        // Pulsante per aprire il dialogo
        PrefDialogButton(
          title: PrefService.of(context).get('timetableurl') != ""
              ? const Text("Link tabella orario")
              : const Text("Cambia link tabella orario"),
          subtitle: PrefService.of(context).get('timetableurl') != ""
              ? Text(PrefService.of(context).get('timetableurl'))
              : null,
          // qui sotto che gestisce l'inserimento del link
          dialog: PrefDialog(
            title: const Text("Link tabella orario"),
            submit: const Text("Ok"),
            onlySaveOnSubmit: true,
            children: [
              // Textbox con validatore link
              PrefText(
                pref: 'timetableurl',
                padding: const EdgeInsets.only(top: 20),
                label: "URL",
                //autofocus: true, rendeva più scomodo secondo me
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: ((value) {
                  if (value == null || value.isEmpty) {
                    return "Hai cancellato tutto...";
                  } else {
                    return isURL(value, allowUnderscore: true)
                        ? null
                        : "Il link non sembra essere completo";
                  }
                }),
              ),
            ],
          ),
          // Ricarica orario quando si preme ok
          onSubmit: (() {
            refreshTimetableData(PrefService.of(context).get('timetableurl'));
          }),
        ),
        // --Accessibilità---
        PrefLabel(
            title: Text(
          "Accessbilità",
          style: catTheme,
        )),
        const PrefSwitch(
          title: Text("Aggiungi spazio sugli elementi estesi"),
          subtitle: Text(
              "Aggiunge dello spazio a lato dell'elemento esteso per distinguerlo meglio dagli altri"),
          pref: 'listViewPadding',
        ),
        const PrefSwitch(
          title: Text("Nascondi sotto menù materia"),
          subtitle: Text("Nasconde prof e classe dopo aver premuto la materia"),
          pref: 'hideSubjectSubmenu',
        ),
        // --Altro-- principalmente pulsanti per link
        PrefLabel(
          title: Text(
            'Altro',
            style: catTheme,
          ),
        ),
        // Link per evitare una denuncia da Icons8
        ListTile(
          title: const Text("Icona 'Orario' da Icons8"),
          onTap: () => openWebsite(
              "https://icons8.com/icon/Z3lbg7ZIDklH/orario", context),
        )
      ]),
    );
  }
}
