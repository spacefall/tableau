import 'package:shared_preferences/shared_preferences.dart';

Future<List<List>> readTTFromLocal(SharedPreferences prefs) async {
  List<List> tt = [
    [], // subject
    [], // prof.
    [], // classroom
    [], //class coordinator
  ];

  final int? listIndexes = prefs.getInt('ttLength');
  if (listIndexes != null) {
    for (int idx = 0; idx <= 2; idx++) {
      for (int i = 0; i < listIndexes; i++) {
        tt[idx].add(prefs.getStringList('ttChunk$idx-$i'));
      }
    }

    final List<String>? chunk3 = prefs.getStringList('ttChunk3');
    if (chunk3 != null) {
      tt[3] = chunk3;
    }
  } else {
    tt = [
      ["nodata"]
    ];
  }

  return tt;
}

void writeTTtoLocal(List<List> tt, SharedPreferences prefs) async {
  for (int idx = 0; idx <= 2; idx++) {
    for (int i = 0; i < tt[0].length; i++) {
      await prefs.setStringList('ttChunk$idx-$i', tt[idx][i].cast<String>());
    }
  }

  await prefs.setStringList('ttChunk3', tt[3].cast<String>());
  await prefs.setInt('ttLength', tt[0].length);
}
