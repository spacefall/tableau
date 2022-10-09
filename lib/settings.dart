import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:validators/validators.dart';

import 'others.dart';
import 'main.dart';

class AppSettings extends StatefulWidget {
  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    final catTheme = TextStyle(color: Theme.of(context).colorScheme.primary);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: PrefPage(children: [
        PrefLabel(
          title: Text(
            'Fonte',
            style: catTheme,
          ),
        ),
        PrefDialogButton(
          title: const Text("Cambia link tabella orario"),
          subtitle: PrefService.of(context).get('timetableurl') != null
              ? Text(PrefService.of(context).get('timetableurl'))
              : null,
          dialog: PrefDialog(
            title: const Text("Link tabella orario"),
            submit: const Text("Ok"),
            onlySaveOnSubmit: true,
            children: [
              PrefText(
                pref: 'timetableurl',
                padding: const EdgeInsets.only(top: 20),
                label: "URL",
                //autofocus: true,
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
          onSubmit: (() {
            refreshTimetableData(PrefService.of(context).get('timetableurl'));
          }),
/*           onDismiss: () {
            delTimetableData();
          }, */
        ),
        PrefLabel(
          title: Text(
            'Altro',
            style: catTheme,
          ),
        ),
        ListTile(
          title: const Text("Icona 'Orario' da Icons8"),
          onTap: () => openWebsite(
              "https://icons8.com/icon/Z3lbg7ZIDklH/orario", context),
        )
      ]),
    );
  }
}
