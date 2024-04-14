import 'package:intl/intl.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';

// This class contains all the Utils used for Date recollection and treatment.
class DateTimeUtils {
  String formatDateTimeToStringDDMMYYYY(DateTime date, String languageCode) {
    return DateFormat("dd-MM-yyyy", languageCode).format(date);
  }

  DateTime formatStringToDateTimeDDMMYYYY(String date, String languageCode) {
    return DateFormat('dd-MM-yyyy', languageCode).parse(date);
  }

  DateTime formatStringToDateTimeDDMMYY(String date, String languageCode) {
    return DateFormat('dd-MM-yy', languageCode).parse(date);
  }

  String formatDateTimeToStringMM(DateTime date, String languageCode) {
    return StringUtils()
        .toCapitalized(DateFormat("MMMM", languageCode).format(date));
  }

  String formatDateTimeToStringMMMYYYY(DateTime date, String languageCode) {
    return StringUtils()
        .toCapitalized(DateFormat("MMM yyyy", languageCode).format(date));
  }

  String formatDateTimeToStringDDMMMMYYYY(DateTime date, String languageCode) {
    return "${StringUtils().toCapitalized(DateFormat("d", languageCode).format(date))} ${StringUtils().toCapitalized(DateFormat("MMMM yyyy", languageCode).format(date))}";
  }

  String formatDateTimeToStringMMYYYY(DateTime date, String languageCode) {
    String result = DateFormat("yyyy", languageCode).format(date);
    return StringUtils().toCapitalized(result);
  }

  String formatDateTimeToStringDDMMYY(DateTime date) {
    return StringUtils().toCapitalized(DateFormat("dd-MM-yy").format(date));
  }
}
