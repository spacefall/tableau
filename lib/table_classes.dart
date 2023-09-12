class Timetable {
  final Map<int, List<Timeslot>> table;

  // Avrei messo il map contenuto nel factory qui sotto come default ma fromJson non funzionerebbe
  /// Inizializza un Timetable vuoto
  factory Timetable() => Timetable._internal(
        <int, List<Timeslot>>{
          0: [],
          1: [],
          2: [],
          3: [],
          4: [],
          5: [],
        },
      );

  Timetable._internal(this.table);

  /// Restituisce Timetable dato un Map<String, dynamic> da json.decode
  factory Timetable.fromJson(Map<String, dynamic> json) => Timetable._internal(
        json.map(
          (key, value) => MapEntry(
            int.parse(key),
            (value as List)
                .map((e) => Timeslot.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        ),
      );

  /// Restituisce un Map<String, dynamic> compatibile con json.encode
  Map<String, dynamic> toJson() => table.map(
        (key, value) => MapEntry(
          key.toString(),
          value.map((e) => e.toJson()).toList(),
        ),
      );

  // Pigrizia lv.100
  @override
  String toString() => toJson().toString();

  /// Aggiunge un Timeslot alla tabella
  void add(int day, Timeslot timeslot) => table.containsKey(day)
      ? table[day]!.add(timeslot)
      : table[day] = [timeslot];
}

class Timeslot {
  String materia;
  String? prof0;
  String? prof1;
  String? classe;

  Timeslot({
    required this.materia,
    this.prof0,
    this.prof1,
    this.classe,
  });

  /// Restituisce un Timeslot dato un Map<String, dynamic> da json.decode
  factory Timeslot.fromJson(Map<String, dynamic> json) => Timeslot(
        materia: json["materia"] as String,
        prof0: json["prof0"] as String,
        prof1: json["prof1"] as String,
        classe: json["classe"] as String,
      );

  /// Restituisce un Map<String, dynamic> compatibile con json.encode
  Map<String, dynamic> toJson() => {
        "materia": materia,
        "prof0": prof0 ?? "",
        "prof1": prof1 ?? "",
        "classe": classe ?? "",
      };
}
