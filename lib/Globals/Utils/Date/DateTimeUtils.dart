import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';

// This class contains all the Utils used for Date recollection and treatment.
class DateTimeUtils {

  String formatDateTimeToStringDDMMYYYY(DateTime date, String languageCode) {
    return DateFormat("dd-MM-yyyy", languageCode).format(date);
  }

  DateTime formatStringToDateTimeDDMMYYYY(String date, String languageCode) {
    return DateFormat('dd-MM-yyyy', languageCode).parse(date);
  }

  String formatDateTimeToStringMM(DateTime date, String languageCode) {
    return StringUtils().toCapitalized(DateFormat("MMMM", languageCode).format(date));
  }

  String formatDateTimeToStringMMYYYY(DateTime date, String languageCode) {
    String result = DateFormat("yyyy", languageCode).format(date);
    return StringUtils().toCapitalized(result);
  }

}
