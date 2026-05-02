import '../features/shared/budget_cycle.dart';
import '../models/budget_models.dart';

String cycleKeyForDate(DateTime date, int cycleStartDay) {
  final cycle = cycleForDate(date, cycleStartDay);
  final month = cycle.start.month.toString().padLeft(2, '0');
  final day = cycle.start.day.toString().padLeft(2, '0');
  return '${cycle.start.year}-$month-$day';
}

String cycleKeyForPeriod(BudgetCyclePeriod cycle) {
  final month = cycle.start.month.toString().padLeft(2, '0');
  final day = cycle.start.day.toString().padLeft(2, '0');
  return '${cycle.start.year}-$month-$day';
}

BudgetData syncBudgetData(BudgetData data, DateTime now) {
  _applyRecurringGoalLinks(data, now);
  _syncPortfolioSnapshots(data, now);
  return data;
}

double currentCycleOpeningBalance(BudgetData data, DateTime now) {
  final currentCycle = cycleForDate(now, data.budgetCycleStartDay);
  final key = cycleKeyForPeriod(currentCycle);
  final snapshot = data.portfolioSnapshots
      .cast<PortfolioSnapshot?>()
      .firstWhere((item) => item?.cycleKey == key, orElse: () => null);
  if (snapshot != null) {
    return snapshot.openingBalance;
  }

  final previous = _sortedSnapshots(data).cast<PortfolioSnapshot?>().lastWhere(
    (item) =>
        item != null &&
        item.cycleEndExclusive.isBefore(currentCycle.endExclusive),
    orElse: () => null,
  );
  return previous?.closingBalance ?? 0;
}

double currentCycleBalance(BudgetData data, DateTime now) {
  final currentCycle = cycleForDate(now, data.budgetCycleStartDay);
  final opening = currentCycleOpeningBalance(data, now);
  final cycleIncome = _netCycleIncome(data, currentCycle);
  final spent = cycleExpenseTotal(data.expenses, currentCycle);
  final recurring = _cycleRecurringTotal(data, currentCycle);
  return opening + cycleIncome - spent - recurring;
}

void _applyRecurringGoalLinks(BudgetData data, DateTime now) {
  final currentCycle = cycleForDate(now, data.budgetCycleStartDay);
  final currentCycleKey = cycleKeyForPeriod(currentCycle);

  for (var index = 0; index < data.recurringAllocations.length; index++) {
    final recurring = data.recurringAllocations[index];
    final goalId = recurring.linkedGoalId;
    if (goalId == null || goalId.isEmpty) {
      continue;
    }
    if (recurring.lastAppliedMonth == currentCycleKey) {
      continue;
    }
    if (recurring.endDate != null &&
        recurring.endDate!.isBefore(currentCycle.start)) {
      continue;
    }

    final goalIndex = data.goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex == -1) {
      data.recurringAllocations[index] = recurring.copyWith(linkedGoalId: '');
      continue;
    }

    final goal = data.goals[goalIndex];
    data.goals[goalIndex] = goal.copyWith(
      currentAmount: goal.currentAmount + recurring.amount,
    );
    data.goalContributions.add(
      GoalContribution(
        id: makeId(),
        goalId: goalId,
        amount: recurring.amount,
        date: currentCycle.start,
        source: 'recurring',
        recurringAllocationId: recurring.id,
      ),
    );
    data.recurringAllocations[index] = recurring.copyWith(
      lastAppliedMonth: currentCycleKey,
    );
  }
}

void _syncPortfolioSnapshots(BudgetData data, DateTime now) {
  final currentCycle = cycleForDate(now, data.budgetCycleStartDay);
  final targetCycles = recentCycles(data.budgetCycleStartDay, count: 24)
      .where((cycle) => cycle.start.isBefore(currentCycle.start))
      .toList()
      .reversed
      .toList();

  final updated = <PortfolioSnapshot>[];
  var openingBalance = 0.0;
  for (final cycle in targetCycles) {
    final cycleKey = cycleKeyForPeriod(cycle);
    final netBaseIncome = data.monthlyIncome - data.monthlyTax;
    final additionalIncome = cycleIncomeTotal(data.incomeEntries, cycle);
    final spent = cycleExpenseTotal(data.expenses, cycle);
    final recurringSpent = _cycleRecurringTotal(data, cycle);
    final goalContributionTotal = data.goalContributions
        .where((item) => cycle.contains(item.date))
        .fold<double>(0, (sum, item) => sum + item.amount);
    final closingBalance =
        openingBalance +
        netBaseIncome +
        additionalIncome -
        spent -
        recurringSpent;

    updated.add(
      PortfolioSnapshot(
        cycleKey: cycleKey,
        cycleStart: cycle.start,
        cycleEndExclusive: cycle.endExclusive,
        openingBalance: openingBalance,
        netBaseIncome: netBaseIncome,
        additionalIncome: additionalIncome,
        spent: spent,
        recurringSpent: recurringSpent,
        goalContributionTotal: goalContributionTotal,
        closingBalance: closingBalance,
      ),
    );
    openingBalance = closingBalance;
  }

  data.portfolioSnapshots
    ..clear()
    ..addAll(updated);
}

double _netCycleIncome(BudgetData data, BudgetCyclePeriod cycle) {
  final baseNet = data.monthlyIncome - data.monthlyTax;
  return baseNet + cycleIncomeTotal(data.incomeEntries, cycle);
}

double _cycleRecurringTotal(BudgetData data, BudgetCyclePeriod cycle) {
  return data.recurringAllocations
      .where((item) {
        if (item.endDate == null) {
          return true;
        }
        return !item.endDate!.isBefore(cycle.start);
      })
      .fold<double>(0, (sum, item) => sum + item.amount);
}

List<PortfolioSnapshot> _sortedSnapshots(BudgetData data) {
  final snapshots = [...data.portfolioSnapshots];
  snapshots.sort((a, b) => a.cycleStart.compareTo(b.cycleStart));
  return snapshots;
}
