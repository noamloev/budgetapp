import 'package:flutter/material.dart';

import '../../models/budget_models.dart';
import '../shared/budget_cycle.dart';
import '../shared/formatters.dart';
import '../shared/widgets/cards.dart';
import '../shared/widgets/help_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.data,
  });

  final BudgetData data;

  @override
  Widget build(BuildContext context) {
    final cycles = recentCycles(data.budgetCycleStartDay, count: 8);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ScreenHeader(
            title: 'History',
            subtitle: 'Review past budget cycles, spending patterns, and income totals in one place.',
            helpTitle: 'History Help',
            helpLines: [
              'Each card represents one full budget cycle based on your cycle start day.',
              'Income and spending totals are grouped by cycle so you can compare periods cleanly.',
              'The recent transactions list inside each cycle helps you inspect what happened.',
            ],
          ),
          const SizedBox(height: 20),
          ...cycles.map(
            (cycle) {
              final expenses = data.expenses.where((item) => cycle.contains(item.date)).toList()
                ..sort((a, b) => b.date.compareTo(a.date));
              final incomes = data.incomeEntries.where((item) => cycle.contains(item.date)).toList()
                ..sort((a, b) => b.date.compareTo(a.date));
              final spent = cycleExpenseTotal(data.expenses, cycle);
              final earned = cycleIncomeTotal(data.incomeEntries, cycle);
              final balance = earned - spent;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cycle.label,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: balance >= 0
                                  ? const Color(0xFFE7F5F3)
                                  : const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              balance >= 0 ? '+${money(balance)}' : money(balance),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: balance >= 0
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFFBE123C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: InfoCard(
                              title: 'Income',
                              value: money(earned),
                              subtitle: '${incomes.length} entries',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InfoCard(
                              title: 'Spent',
                              value: money(spent),
                              subtitle: '${expenses.length} entries',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (expenses.isEmpty && incomes.isEmpty)
                        const Text(
                          'No activity in this cycle.',
                          style: TextStyle(color: Colors.black54),
                        )
                      else ...[
                        if (incomes.isNotEmpty) ...[
                          Text('Income', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ...incomes.take(3).map(
                            (income) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InfoRowCard(
                                title: income.contributor,
                                subtitle: '${income.title} - ${formatDayMonth(income.date)}',
                                trailing: money(income.amount),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        if (expenses.isNotEmpty) ...[
                          Text('Expenses', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ...expenses.take(5).map(
                            (expense) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ExpenseListTile(expense: expense),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
