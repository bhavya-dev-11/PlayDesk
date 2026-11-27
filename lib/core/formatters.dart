import 'package:intl/intl.dart';

/// INR currency formatter (₹1,234).
final _inrFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// Compact INR formatter (₹1.2K, ₹12K).
final _inrCompactFormat = NumberFormat.compactCurrency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 1,
);

/// Formats an integer amount in paise to INR string.
/// Assumes input is in rupees (not paise) for simplicity.
String formatINR(int rupees) => _inrFormat.format(rupees);

/// Formats an integer amount in rupees to compact INR string.
String formatINRCompact(int rupees) => _inrCompactFormat.format(rupees);

/// Formats a number with Indian grouping (1,23,456).
String formatNumber(int n) => NumberFormat('#,##,##0', 'en_IN').format(n);

/// Formats a decimal number (e.g., percentages).
String formatDecimal(double n, {int fractionDigits = 1}) =>
    NumberFormat('#,##0.${'0' * fractionDigits}', 'en_IN').format(n);

/// Formats a percentage (0.123 -> "12.3%").
String formatPercent(double fraction, {int fractionDigits = 1}) =>
    '${formatDecimal(fraction * 100, fractionDigits: fractionDigits)}%';

/// Formats a duration in hours/minutes nicely.
String formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours > 0 && minutes > 0) {
    return '${hours}h ${minutes}m';
  } else if (hours > 0) {
    return '${hours}h';
  } else {
    return '${minutes}m';
  }
}

/// Formats a DateTime as time only (h:mm a).
String formatTime(DateTime dt) => DateFormat('h:mm a').format(dt);

/// Formats a DateTime as date only (EEE, MMM d).
String formatDate(DateTime dt) => DateFormat('EEE, MMM d').format(dt);

/// Formats a DateTime as date and time (EEE, MMM d at h:mm a).
String formatDateTime(DateTime dt) => DateFormat('EEE, MMM d \'at\' h:mm a').format(dt);

/// Pluralizes a noun based on count.
/// e.g., pluralize(1, 'player') -> '1 player'
///       pluralize(2, 'player') -> '2 players'
///       pluralize(1, 'session', 'sessions') -> '1 session'
String pluralize(int count, String singular, [String? plural]) {
  final p = plural ?? '${singular}s';
  return '$count ${count == 1 ? singular : p}';
}

/// Formats a ratio as "X of Y" (e.g., "12 of 50").
String formatRatio(int numerator, int denominator) =>
    '$numerator of $denominator';

/// Formats a change with direction (e.g., "+₹500", "-₹200", "₹0").
String formatChange(int change) {
  if (change > 0) return '+${formatINR(change)}';
  if (change < 0) return formatINR(change); // already has minus
  return formatINR(0);
}