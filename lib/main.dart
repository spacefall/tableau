import "package:dynamic_color/dynamic_color.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:pref/pref.dart";
import "package:tableau/home.dart";
import "package:timetable/timetable.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final service = await PrefServiceShared.init(
    defaults: {
      "ttUrl": "",
      "alwaysUseStandardTime": false,
    },
  );
  //runApp(const Tableau());
  runApp(
    PrefService(
      service: service,
      child: const Tableau(),
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, //black.withOpacity(0),
    ),
  );
}

class Tableau extends StatelessWidget {
  const Tableau({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = "Tableau";
    const Color nonDynamicColor = Color(0xff5fa777);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme darkTheme;
        ColorScheme lightTheme;

        // Usa schema colori dinamico se possiblile
        // Quando invece non è disponibile ne crea uno basato su #5fa777 (const nonDynamicColor)
        if (lightDynamic != null && darkDynamic != null) {
          lightTheme = lightDynamic.harmonized();
          darkTheme = darkDynamic.harmonized();
        } else {
          lightTheme = ColorScheme.fromSeed(
            seedColor: nonDynamicColor,
          ).harmonized();
          darkTheme = ColorScheme.fromSeed(
            seedColor: nonDynamicColor,
            brightness: Brightness.dark,
          ).harmonized();
        }

        return MaterialApp(
          // Abilita lingue diverse dall'inglese
          localizationsDelegates: const [
            TimetableLocalizationsDelegate(), // Richiesto da timetable
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Forza l'italiano
          supportedLocales: const [Locale("it")],
          title: appTitle,
          theme: ThemeData(
            colorScheme: lightTheme,
            //scaffoldBackgroundColor: lightTheme.background,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkTheme,
            //scaffoldBackgroundColor: darkTheme.background,
            useMaterial3: true,
          ),
          home: TableauHome(
            title: appTitle,
            ttUrl: PrefService.of(context).get("ttUrl") as String,
          ),
        );
      },
    );
  }
}
