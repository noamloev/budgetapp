String money(double value) => '₪${value.toStringAsFixed(0)}';

String formatMonthYear(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '$month/${date.year}';
}
