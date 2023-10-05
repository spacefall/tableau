import "package:flutter/material.dart";
import "package:pref/pref.dart";
import "package:string_validator/string_validator.dart";

class TableauSettings extends StatefulWidget {
  const TableauSettings({super.key, required this.refreshParent});

  //final VoidCallback setTTPage;
  final Function({bool deepRefresh}) refreshParent;

  @override
  State<TableauSettings> createState() => _TableauSettingsState();
}

class _TableauSettingsState extends State<TableauSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Impostazioni"),
      ),
      body: ListView(
        children: [
          PrefDialogButton(
            title: const Text("URL tabella oraria"),
            // TODO: lo odio, sicuramente c'è una soluzione migliore. mettila.
            subtitle: PrefService.of(context).get("ttUrl") == ""
                ? null
                : Text(PrefService.of(context).get("ttUrl") as String),
            onSubmit: () => widget.refreshParent(deepRefresh: true),
            //onSubmit: () => parentsetTimetablePage(PrefService.of(context).get("ttUrl")),
            //onSubmit: () => setState(() {}),
            dialog: PrefDialog(
              title: const Text("URL tabella oraria"),
              submit: const Text("Salva"),
              cancel: const Text("Cancella"),
              onlySaveOnSubmit: true,
              children: [
                Center(
                  child: PrefText(
                    pref: "ttUrl",
                    autofocus: true,
                    validator: (input) =>
                        isURL(input, {"allow_underscores": true})
                            ? null
                            : "L'url non sembra corretto",
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Inserisci l'url dell'orario"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          PrefSwitch(
            pref: "alwaysUseStandardTime",
            title: const Text(
              "Usa orario intero per tutti i giorni",
            ),
            onChange: (v) => widget.refreshParent(),
          ),
        ],
      ),
    );
  }
}
