import 'package:intl/intl.dart';

final _date = DateFormat('d MMM y');
final _dateShort = DateFormat('d MMM');

String fmtDate(DateTime d) => _date.format(d);
String fmtDateShort(DateTime d) => _dateShort.format(d);

String fmtMoney(int amountMinor, String currency) =>
    NumberFormat.simpleCurrency(locale: currency == 'INR' ? 'en_IN' : 'en', name: currency)
        .format(amountMinor / 100);

/// "1250.50" → 125050. Returns null for empty or invalid input.
int? parseMoney(String text) {
  final cleaned = text.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  final v = double.tryParse(cleaned);
  return v == null ? null : (v * 100).round();
}

String fmtMinutes(int minutes) {
  final dt = DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60);
  return DateFormat.jm().format(dt);
}

/// 30 → "30 days before", 0 → "On the day", -1 → "1 day after".
String offsetLabel(int d) {
  if (d == 0) return 'On the day';
  if (d == 1) return '1 day before';
  if (d == -1) return '1 day after';
  return d > 0 ? '$d days before' : '${-d} days after';
}
