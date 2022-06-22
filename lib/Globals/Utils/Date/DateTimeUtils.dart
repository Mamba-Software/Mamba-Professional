import 'package:intl/intl.dart';

// This class contains all the Utils used for Date recollection and treatment.
class DateTimeUtils {

  String formatDateTimeToStringDDMMYYYY(DateTime date, String languageCode) {
    return DateFormat("dd-MM-yyyy", languageCode).format(date);
  }

  DateTime formatStringToDateTimeDDMMYYYY(String date, String languageCode) {
    return DateFormat('dd-MM-yyyy', languageCode).parse(date);
  }

}
