import 'package:flutter/material.dart';

import '../../shared/expense_categories.dart';
import '../../shared/widgets/app_sheet.dart';

class CategoryBudgetSheet extends StatefulWidget {
  const CategoryBudgetSheet({
    super.key,
    required this.initialBudgets,
  });

  final Map<String, double> initialBudgets;

  @override
  State<CategoryBudgetSheet> createState() => _CategoryBudgetSheetState();
}

class _CategoryBudgetSheetState extends State<CategoryBudgetSheet> {
  late final Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = {
      for (final category in ExpenseCategory.values)
        category.label: TextEditingController(
          text: widget.initialBudgets[category.label]?.toStringAsFixed(0) ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: 'Category Budgets',
      helpTitle: 'Category Budgets',
      helpLines: const [
        'Set optional category limits to see where overspending happens.',
        'Leave a field empty if you do not want a separate budget for that category.',
      ],
      child: Column(
        children: [
          ...ExpenseCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: controllers[category.label],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: category.label),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final budgets = <String, double>{};
                for (final entry in controllers.entries) {
                  final text = entry.value.text.trim();
                  if (text.isEmpty) {
                    continue;
                  }
                  final amount = double.tryParse(text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid budget for ${entry.key}.')),
                    );
                    return;
                  }
                  budgets[entry.key] = amount;
                }
                Navigator.pop(context, budgets);
              },
              child: const Text('Save Category Budgets'),
            ),
          ),
        ],
      ),
    );
  }
}
