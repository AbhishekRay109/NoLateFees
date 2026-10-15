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

/// Turns what people type into E.164. Ten-digit numbers are assumed to be
/// Indian (+91). Returns null if it can't be a valid number.
String? normalizePhone(String input, {String defaultCountryCode = '+91'}) {
  var s = input.replaceAll(RegExp(r'[\s\-().]'), '');
  if (s.isEmpty) return null;
  if (s.startsWith('00')) s = '+${s.substring(2)}';
  if (!s.startsWith('+')) {
    if (s.startsWith('0')) s = s.substring(1);
    if (defaultCountryCode == '+91' && s.length == 12 && s.startsWith('91')) {
      s = '+$s';
    } else {
      s = '$defaultCountryCode$s';
    }
  }
  if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(s)) return null;
  if (s.startsWith('+91') && !RegExp(r'^\+91[6-9]\d{9}$').hasMatch(s)) return null;
  return s;
}

bool isValidEmail(String input) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input.trim());

/// "+919876543210" → "+91 98765 43210" for display.
String formatPhone(String e164) {
  if (RegExp(r'^\+91\d{10}$').hasMatch(e164)) {
    return '+91 ${e164.substring(3, 8)} ${e164.substring(8)}';
  }
  return e164;
}

/// "Sumaiya Mansoor" → "SM", for avatars.
String initialsOf(String? name) {
  final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '🙂';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}
