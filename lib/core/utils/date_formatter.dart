import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateFormatter {
  DateFormatter._();

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Az önce';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} dakika önce';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} saat önce';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(dateTime);
    }
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy', 'tr_TR').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'tr_TR').format(dateTime);
  }

  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm', 'tr_TR').format(dateTime);
  }
}
