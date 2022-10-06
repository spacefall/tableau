import 'package:jiffy/jiffy.dart';

int checkIfInvalid(int month, int day) {
  Jiffy dateNow = Jiffy();
  Jiffy dateThen = Jiffy([dateNow.year, month, day]);
  return dateNow.diff(dateThen, Units.DAY).toInt();
}

String updateLink(String link, int month, int day, int diff) {
  Jiffy dateUpdated = Jiffy([Jiffy().year, month, day]); //.add(days: 7);
/*   while (checkIfInvalid(dateUpdated.month, dateUpdated.day)) {
    dateUpdated =
        Jiffy([Jiffy().year, dateUpdated.month, dateUpdated.day]).add(days: 7);
  } */
  dateUpdated.add(days: diff);
  dateUpdated.subtract(days: dateUpdated.day - 1);
  dateUpdated = correctDate(dateUpdated);
  return link.replaceAll("%DATE%",
      "${dateUpdated.date.toString()}-${dateUpdated.month.toString()}");
}

Jiffy correctDate(Jiffy date) {
  if (date.month == 11 && date.day == 1) {
    date.add(days: 1);
  }
  return date;
}
