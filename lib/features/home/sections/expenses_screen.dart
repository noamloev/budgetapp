import 'package:flutter/material.dart';

import '../../../models/budget_models.dart';
import '../../shared/expense_categories.dart';
import '../../shared/widgets/cards.dart';
import '../../shared/widgets/empty_state_card.dart';
import '../../shared/widgets/help_widgets.dart';
import '../forms/expense_form_sheet.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({
    super.key,
    required this.expenses,
    required this.onUpsertExpense,
    required this.onDeleteExpense,
  });

  final List<Expense> expenses;
  final ValueChanged<Expense> onUpsertExpense;
  final ValueChanged<String> onDeleteExpense;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final searchController = TextEditingController();
  String selectedCategory = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _openExpenseSheet([Expense? expense]) async {
    final result = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseFormSheet(initialExpense: expense),
    );
    if (result != null) {
      widget.onUpsertExpense(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final filtered = widget.expenses.where((expense) {
      final matchesQuery = query.isEmpty ||
          expense.title.toLowerCase().contains(query) ||
          expense.note.toLowerCase().contains(query) ||
          expense.account.toLowerCase().contains(query);
      final matchesCategory =
          selectedCategory == 'All' || expense.category == selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ScreenHeader(
            title: 'Expenses',
            subtitle: 'Track payments, search old entries, and manage categories for this budget.',
            helpTitle: 'Expenses Help',
            helpLines: const [
              'Add every payment here so the dashboard and reports stay accurate.',
              'Search by name or note. Filter by category to inspect spending patterns.',
              'Use the three-dot menu on each payment to edit or delete it.',
              'Everything here belongs to the current login account budget.',
            ],
            action: FilledButton.icon(
              onPressed: _openExpenseSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Payment'),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Search payments',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedCategory == 'All',
                  onSelected: (_) => setState(() => selectedCategory = 'All'),
                ),
                const SizedBox(width: 8),
                ...ExpenseCategory.values.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(item.label),
                      selected: selectedCategory == item.label,
                      onSelected: (_) => setState(() => selectedCategory = item.label),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (widget.expenses.isEmpty)
            EmptyStateCard(
              icon: Icons.receipt_long_rounded,
              title: 'No payments yet',
              subtitle:
                  'Start logging what you spend so the app can show patterns and real budget progress.',
              actionLabel: 'Add First Payment',
              onTap: _openExpenseSheet,
            )
          else if (filtered.isEmpty)
            EmptyStateCard(
              icon: Icons.filter_alt_off_rounded,
              title: 'No matching payments',
              subtitle: 'Try a different search term or category filter.',
              actionLabel: 'Nothing to open',
              onTap: _noop,
            )
          else
            ...filtered.map(
              (expense) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExpenseListTile(
                  expense: expense,
                  onEdit: () => _openExpenseSheet(expense),
                  onDelete: () => widget.onDeleteExpense(expense.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _noop() {}
