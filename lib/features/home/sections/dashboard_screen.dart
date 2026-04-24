import 'package:flutter/material.dart';

import '../../../models/budget_models.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/help_widgets.dart';
import '../forms/income_form_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.data,
    required this.onStartSetup,
    required this.onUpsertIncome,
    required this.onDeleteIncome,
  });

  final BudgetData data;
  final VoidCallback onStartSetup;
  final ValueChanged<IncomeEntry> onUpsertIncome;
  final ValueChanged<String> onDeleteIncome;

  @override
  Widget build(BuildContext context) {
    if (!data.hasBudgetSetup) {
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ScreenHeader(
              title: 'Dashboard',
              subtitle: 'This is the main money overview screen.',
              helpTitle: 'Dashboard Help',
              helpLines: const [
                'The dashboard shows your net income, budget progress, recent payments, and category trends.',
                'You need core budget numbers first before these widgets can become useful.',
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF115E59), Color(0xFFE76F51)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Your Budget',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add your monthly income, tax, and spending goal first. Then you can track payments, recurring allocations, and future dreams.',
                    style: TextStyle(color: Colors.white70, height: 1.45),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onStartSetup,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF115E59),
                    ),
                    child: const Text('Fill Important Data'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final incomeAfterTax = data.monthlyIncome - data.monthlyTax;
    final spent = data.totalSpent;
    final recurring = data.totalRecurring;
    final incomeThisMonth = data.incomeEntries
        .where((item) => item.date.year == DateTime.now().year && item.date.month == DateTime.now().month)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final totalUsableIncome = incomeAfterTax + incomeThisMonth;
    final freeToUse = totalUsableIncome - spent - recurring;
    final goalProgress =
        data.monthlySpendingGoal <= 0 ? 0.0 : (spent / data.monthlySpendingGoal).clamp(0.0, 1.0);
    final dailySafeSpend =
        (((data.monthlySpendingGoal - spent) / 10).clamp(0.0, double.infinity)).toDouble();
    final charity = data.recurringAllocations
        .where((item) => item.category == 'Charity')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final spentByCategory = <String, double>{};
    for (final expense in data.expenses) {
      spentByCategory.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    final topCategories = Map<String, double>.fromEntries(
      spentByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
    final reviewText = spent <= data.monthlySpendingGoal
        ? 'You are inside your monthly target by ${money(data.monthlySpendingGoal - spent)}.'
        : 'You are above your monthly target by ${money(spent - data.monthlySpendingGoal)}.';

    Future<void> openIncome([IncomeEntry? income]) async {
      final result = await showModalBottomSheet<IncomeEntry>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => IncomeFormSheet(initialIncome: income),
      );
      if (result != null) {
        onUpsertIncome(result);
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ScreenHeader(
            title: 'Dashboard',
            subtitle: 'Your main overview of income, spending, savings behavior, and progress.',
            helpTitle: 'Dashboard Help',
            helpLines: const [
              'Net Income is income after tax.',
              'Add Income lets each partner record how much they put in this month.',
              'Monthly Goal compares spending against the limit you set.',
              'Money Map highlights the biggest money buckets.',
              'Category bars and monthly review help you quickly spot problems.',
              'Everything on this screen belongs to the current login account budget.',
            ],
            action: FilledButton.icon(
              onPressed: () => openIncome(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Income'),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF115E59), Color(0xFFE76F51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Flow',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A clean view of income, spending, automatic allocations, and long-term goals.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SummaryChip(label: 'Net Income', value: money(incomeAfterTax)),
                    SummaryChip(label: 'Added This Month', value: money(incomeThisMonth)),
                    SummaryChip(label: 'Spent', value: money(spent)),
                    SummaryChip(label: 'Free Left', value: money(freeToUse)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: 'Monthly Goal',
                  value: money(data.monthlySpendingGoal),
                  subtitle:
                      '${(goalProgress * 100).toStringAsFixed(0)}% of spending target used',
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: LinearProgressIndicator(
                      value: goalProgress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InfoCard(
                  title: 'Daily Safe Spend',
                  value: money(dailySafeSpend),
                  subtitle: 'Simple runway estimate for the rest of the month',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Money Map', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  color: const Color(0xFF1D4ED8),
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Base Net Income',
                  value: money(incomeAfterTax),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatTile(
                  color: const Color(0xFFB45309),
                  icon: Icons.groups_rounded,
                  title: 'Added This Month',
                  value: money(incomeThisMonth),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  color: const Color(0xFF7C3AED),
                  icon: Icons.autorenew_rounded,
                  title: 'Automatic Spending',
                  value: money(recurring),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatTile(
                  color: const Color(0xFFBE123C),
                  icon: Icons.flag_rounded,
                  title: 'Goals Saved',
                  value: money(data.totalGoalSaved),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatTile(
            color: const Color(0xFFBE123C),
            icon: Icons.volunteer_activism_rounded,
            title: 'Giving',
            value: money(charity),
          ),
          const SizedBox(height: 20),
          Text('Income This Month', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (data.incomeEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'No income entries yet. Use Add Income to record what each person added this month.',
                style: TextStyle(color: Colors.black54, height: 1.4),
              ),
            )
          else
            ...data.incomeEntries.take(5).map(
              (income) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InfoRowCard(
                  title: income.contributor,
                  subtitle: '${income.title} - ${formatMonthYear(income.date)}',
                  trailing: money(income.amount),
                  onEdit: () => openIncome(income),
                  onDelete: () => onDeleteIncome(income.id),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text('Category Snapshot', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (topCategories.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'No category data yet. Add payments from the Expenses tab.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            MiniBarChart(values: Map.fromEntries(topCategories.entries.take(5))),
          const SizedBox(height: 20),
          Text('Monthly Review', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          InfoCard(
            title: 'How this month looks',
            value: money(spent),
            subtitle: reviewText,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Recurring allocations currently reserve ${money(recurring)} and your goals already hold ${money(data.totalGoalSaved)}.',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Recent Spending', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (data.expenses.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'No spending logged yet. Add your first payment from the Expenses tab and the dashboard will start showing patterns.',
                style: TextStyle(color: Colors.black54, height: 1.4),
              ),
            )
          else
            ...data.expenses.take(4).map(
                  (expense) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ExpenseListTile(expense: expense),
              ),
            ),
        ],
      ),
    );
  }
}
