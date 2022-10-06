import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pref/pref.dart';

import 'local_timetable.dart';
import 'get_new_timetable.dart';
import 'update_link.dart';
import 'settings.dart';

late final SharedPreferences prefs;
List<List> times = [[]];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Jiffy.locale("it");

  prefs = await SharedPreferences.getInstance();

  final service = await PrefServiceShared.init(
    defaults: {
      'timetableurl': '',
    },
  );

  times = await readTTFromLocal(prefs);
  if (times[0][0] == "nodata") {
    //print("Using remote timetable, replace this with inital setup");
    print(service.get('timetableurl'));
    /* if (service.get('timetableurl') == "") {
      times = await getNewTimetable(
          );
      writeTTtoLocal(times, prefs);
    } */
  } else {
    int dateDiff =
        checkIfInvalid(int.parse(times[3][2]), int.parse(times[3][1]));
    if (dateDiff < 6) {
      print("Using local timetable");
    } else {
      print("Getting remote Timetable");
      String ttUrl = updateLink(times[3][3], int.parse(times[3][2]),
          int.parse(times[3][1]), dateDiff);
      times = await getNewTimetable(ttUrl);
      writeTTtoLocal(times, prefs);
    }
  }
  runApp(
    PrefService(
      service: service,
      child: const MyApp(),
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black.withOpacity(0),
  ));
}

const Color baseColor = Color.fromARGB(255, 0, 153, 47);
const List<String> dayNames = [
  "Lunedì",
  "Martedì",
  "Mercoledì",
  "Giovedì",
  "Venerdì",
  "Sabato",
];

const String firstRun = """
Sembra che sia la prima volta che apri questa applicazione.

Per iniziare vai sul sito della scuola e vai su:
Orario delle lezioni > Orario singole classi > la tua classe.

Copia il link ed incollalo in:
Impostazioni (l'ingranaggio in alto a sinistra) > Link orario scuola.
""";

void refreshTimetableData(String url) async {
  times = await getNewTimetable(url);
  writeTTtoLocal(times, prefs);
}

void delTimetableData() async {
  await prefs.clear();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme darkTheme;
      ColorScheme lightTheme;

      if (lightDynamic != null && darkDynamic != null) {
        lightTheme = lightDynamic.harmonized();
        darkTheme = darkDynamic.harmonized();
      } else {
        lightTheme = ColorScheme.fromSeed(seedColor: baseColor);
        darkTheme = ColorScheme.fromSeed(
            seedColor: baseColor, brightness: Brightness.dark);
      }

      return MaterialApp(
        title: 'Tableau',
        theme: ThemeData(
          colorScheme: lightTheme,
          scaffoldBackgroundColor: lightTheme.background,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkTheme,
          scaffoldBackgroundColor: darkTheme.background,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const MyHomePage(title: 'Tableau'),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    AppBar bartender = AppBar(
      title: Text(widget.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: "Impostazioni",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppSettings()),
            ).then((value) => setState(() {}));
/*             Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AppSettings(),
            )); */
          },
        ),
      ],
    );

    if (times[0][0] != "nodata") {
      return Scaffold(
        appBar: bartender,
        body: ListView(
          physics: const ScrollPhysics(),
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayNames.length,
              itemBuilder: (context, indice) {
                return ExpansionTile(
                  initiallyExpanded: (dayNames[indice].toLowerCase() ==
                      Jiffy().format("EEEE")),
                  title: Text(dayNames[indice]),
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: times[0].length - 1,
                        itemBuilder: (BuildContext context, int index) {
                          return ExpansionTile(
                            title: Text(times[0][index + 1][indice]),
                            children: [
                              ListTile(
                                title: Text(
                                    "Prof: ${times[1][index + 1][indice]}"),
                              ),
                              ListTile(
                                title: Text(
                                    "Classe: ${times[2][index + 1][indice]}"),
                              ),
                            ],
                          );
                        })
                  ],
                );
              },
            ),
            ListTile(
              title: Text(times[3][0]),
            )
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: bartender,
        body: const ListTile(
          title: Text(
            firstRun,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ),
      );
    }
  }
}
