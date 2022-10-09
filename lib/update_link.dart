import 'package:jiffy/jiffy.dart';

// Restituisce se differenza tra il giorno corrente e la data dell'orario > 6
// Usata per la funzione sotto a questa e anche per capire se la tabella va cambiata
bool isDateValid(int month, int day) {
  Jiffy dateNow = Jiffy();
  Jiffy dateThen = Jiffy([dateNow.year, month, day]);
  return (dateNow.diff(dateThen, Units.DAY).toInt() < 6);
}

// Cambia la data della tabella oraria
// Questa funzione non è più usata e verrà eliminata in futuro, vedi updateLinkv2 aka la funzione sotto
/* String updateLink(String link, int month, int day, int diff) {
  Jiffy dateUpdated = Jiffy([Jiffy().year, month, day]); //.add(days: 7);
  dateUpdated.add(days: diff);
  dateUpdated.subtract(days: dateUpdated.day - 1);
  dateUpdated = correctDate(dateUpdated);
  return link.replaceAll("%DATE%",
      "${dateUpdated.date.toString()}-${dateUpdated.month.toString()}");
} */

// Cambia la data della tabella oraria
String updateLink(String link) {
  Jiffy dateRN = Jiffy().subtract(days: Jiffy().day - 1);
  Jiffy dateRNCorrected = correctDate(dateRN);
  return link.replaceAll("%DATE%",
      "${dateRNCorrected.date.toString()}-${dateRNCorrected.month.toString()}");
}

// Corregge la data se per esempio il 1° novembre è festa ed è anche lunedì
Jiffy correctDate(Jiffy date) {
  if (date.month == 11 && date.day == 1) {
    date.add(days: 1);
  }
  return date;
}
