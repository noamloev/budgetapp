String money(double value) => '₪${value.toStringAsFixed(0)}';

String formatMonthYear(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '$month/${date.year}';
}

String formatDayMonth(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}
