import '../../models/budget_models.dart';

class BudgetCyclePeriod {
  BudgetCyclePeriod({
    required this.start,
    required this.endExclusive,
  });

  final DateTime start;
  final DateTime endExclusive;

  String get label =>
      '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}'
      ' - '
      '${endExclusive.subtract(const Duration(days: 1)).day.toString().padLeft(2, '0')}/${endExclusive.subtract(const Duration(days: 1)).month.toString().padLeft(2, '0')}/${endExclusive.subtract(const Duration(days: 1)).year}';

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(endExclusive);
}

DateTime _safeMonthDate(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  final safeDay = day > lastDay ? lastDay : day;
  return DateTime(year, month, safeDay);
}

BudgetCyclePeriod cycleForDate(DateTime date, int cycleStartDay) {
  final currentMonthStart = _safeMonthDate(date.year, date.month, cycleStartDay);
  final start = date.isBefore(currentMonthStart)
      ? _safeMonthDate(date.year, date.month - 1, cycleStartDay)
      : currentMonthStart;
  final endExclusive = _safeMonthDate(start.year, start.month + 1, cycleStartDay);
  return BudgetCyclePeriod(start: start, endExclusive: endExclusive);
}

List<BudgetCyclePeriod> recentCycles(int cycleStartDay, {int count = 6}) {
  final cycles = <BudgetCyclePeriod>[];
  var cursor = DateTime.now();
  for (var i = 0; i < count; i++) {
    final cycle = cycleForDate(cursor, cycleStartDay);
    cycles.add(cycle);
    cursor = cycle.start.subtract(const Duration(days: 1));
  }
  return cycles;
}

double cycleExpenseTotal(List<Expense> expenses, BudgetCyclePeriod cycle) {
  return expenses
      .where((item) => cycle.contains(item.date))
      .fold<double>(0, (sum, item) => sum + item.amount);
}

double cycleIncomeTotal(List<IncomeEntry> incomes, BudgetCyclePeriod cycle) {
  return incomes
      .where((item) => cycle.contains(item.date))
      .fold<double>(0, (sum, item) => sum + item.amount);
}
