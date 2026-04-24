import 'package:flutter/material.dart';

import '../../../models/budget_models.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/empty_state_card.dart';
import '../../shared/widgets/help_widgets.dart';
import '../forms/budget_settings_sheet.dart';
import '../forms/category_budget_sheet.dart';
import '../forms/goal_contribution_sheet.dart';
import '../forms/goal_form_sheet.dart';
import '../forms/recurring_form_sheet.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({
    super.key,
    required this.data,
    required this.onUpdateBudgetSettings,
    required this.onUpdateCategoryBudgets,
    required this.onUpsertRecurring,
    required this.onDeleteRecurring,
    required this.onUpsertGoal,
    required this.onDeleteGoal,
    required this.onContributeToGoal,
  });

  final BudgetData data;
  final void Function({
    required double monthlyIncome,
    required double monthlyTax,
    required double monthlyGoal,
  }) onUpdateBudgetSettings;
  final ValueChanged<Map<String, double>> onUpdateCategoryBudgets;
  final ValueChanged<RecurringAllocation> onUpsertRecurring;
  final ValueChanged<String> onDeleteRecurring;
  final ValueChanged<FinancialGoal> onUpsertGoal;
  final ValueChanged<String> onDeleteGoal;
  final void Function(String goalId, double amount) onContributeToGoal;

  Future<void> _openBudgetSheet(BuildContext context) async {
    final result = await showModalBottomSheet<BudgetSettingsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetSettingsSheet(data: data),
    );
    if (result != null) {
      onUpdateBudgetSettings(
        monthlyIncome: result.monthlyIncome,
        monthlyTax: result.monthlyTax,
        monthlyGoal: result.monthlyGoal,
      );
    }
  }

  Future<void> _openCategoryBudgets(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, double>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryBudgetSheet(initialBudgets: data.categoryBudgets),
    );
    if (result != null) {
      onUpdateCategoryBudgets(result);
    }
  }

  Future<void> _openRecurring(BuildContext context, [RecurringAllocation? item]) async {
    final result = await showModalBottomSheet<RecurringAllocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecurringFormSheet(initialItem: item),
    );
    if (result != null) {
      onUpsertRecurring(result);
    }
  }

  Future<void> _openGoal(BuildContext context, [FinancialGoal? goal]) async {
    final result = await showModalBottomSheet<FinancialGoal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GoalFormSheet(initialGoal: goal),
    );
    if (result != null) {
      onUpsertGoal(result);
    }
  }

  Future<void> _openContribution(BuildContext context, FinancialGoal goal) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GoalContributionSheet(),
    );
    if (amount != null) {
      onContributeToGoal(goal.id, amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ScreenHeader(
            title: 'Planning',
            subtitle: 'Manage your core budget, category limits, recurring money moves, and long-term goals.',
            helpTitle: 'Planning Help',
            helpLines: const [
              'Edit your monthly numbers here when income, tax, or your spending target changes.',
              'Category budgets help you spot overspending earlier.',
              'Recurring items and goals can both be edited from their menus.',
            ],
          ),
          const SizedBox(height: 20),
          InfoCard(
            title: 'Income & Target',
            value:
                '${money(data.monthlyIncome - data.monthlyTax)} net / ${money(data.monthlySpendingGoal)} goal',
            subtitle: 'Your after-tax income against your monthly spending limit',
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: () => _openBudgetSheet(context),
                    child: const Text('Edit Numbers'),
                  ),
                  OutlinedButton(
                    onPressed: () => _openCategoryBudgets(context),
                    child: const Text('Category Budgets'),
                  ),
                ],
              ),
            ),
          ),
          if (data.categoryBudgets.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...data.categoryBudgets.entries.map(
              (entry) {
                final spent = data.expenses
                    .where((expense) => expense.category == entry.key)
                    .fold<double>(0, (sum, expense) => sum + expense.amount);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InfoCard(
                    title: entry.key,
                    value: '${money(spent)} / ${money(entry.value)}',
                    subtitle: spent > entry.value
                        ? 'Over budget by ${money(spent - entry.value)}'
                        : 'Remaining ${money(entry.value - spent)}',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(
                        value: entry.value <= 0 ? 0 : (spent / entry.value).clamp(0.0, 1.0),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Automatic Spending',
            actionLabel: 'Add',
            onTap: () => _openRecurring(context),
          ),
          const SizedBox(height: 12),
          if (data.recurringAllocations.isEmpty)
            EmptyStateCard(
              icon: Icons.autorenew_rounded,
              title: 'No automatic spending yet',
              subtitle:
                  'Add investing, charity, savings, or bills so your monthly plan reflects real life.',
              actionLabel: 'Add Allocation',
              onTap: () => _openRecurring(context),
            )
          else
            ...data.recurringAllocations.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InfoRowCard(
                  title: item.name,
                  subtitle: item.category == 'Loan' && item.endDate != null
                      ? '${item.category} - ${item.schedule} - until ${formatMonthYear(item.endDate!)}'
                      : '${item.category} - ${item.schedule}',
                  trailing: money(item.amount),
                  onEdit: () => _openRecurring(context, item),
                  onDelete: () => onDeleteRecurring(item.id),
                ),
              ),
            ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Goals & Dreams',
            actionLabel: 'Add',
            onTap: () => _openGoal(context),
          ),
          const SizedBox(height: 12),
          if (data.goals.isEmpty)
            EmptyStateCard(
              icon: Icons.flag_rounded,
              title: 'No goals yet',
              subtitle:
                  'Add a trip, emergency fund, car, home, or another dream so your budget stays connected to something meaningful.',
              actionLabel: 'Add Goal',
              onTap: () => _openGoal(context),
            )
          else
            ...data.goals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalCard(
                  goal: goal,
                  onContribute: () => _openContribution(context, goal),
                  onEdit: () => _openGoal(context, goal),
                  onDelete: () => onDeleteGoal(goal.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
