import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:pref/pref.dart";
import "package:string_validator/string_validator.dart";

class TableauSettings extends StatefulWidget {
  const TableauSettings({super.key, required this.setTTPage});

  final VoidCallback setTTPage;

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
      body: PrefDialogButton(
        title: const Text("URL tabella oraria"),
        // TODO: lo odio, sicuramente c'è una soluzione migliore. mettila.
        subtitle: PrefService.of(context).get("ttUrl") == ""
            ? null
            : Text(PrefService.of(context).get("ttUrl") as String),
        onSubmit: () => widget.setTTPage(),
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
                validator: (input) => isURL(input, {"allow_underscores": true})
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
    );
  }
}
