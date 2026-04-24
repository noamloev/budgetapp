import 'package:flutter/material.dart';

import '../../../models/budget_models.dart';
import '../../shared/widgets/app_sheet.dart';

class IncomeFormSheet extends StatefulWidget {
  const IncomeFormSheet({
    super.key,
    this.initialIncome,
  });

  final IncomeEntry? initialIncome;

  @override
  State<IncomeFormSheet> createState() => _IncomeFormSheetState();
}

class _IncomeFormSheetState extends State<IncomeFormSheet> {
  late final TextEditingController contributorController;
  late final TextEditingController titleController;
  late final TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialIncome;
    contributorController = TextEditingController(text: initial?.contributor ?? '');
    titleController = TextEditingController(text: initial?.title ?? '');
    amountController = TextEditingController(
      text: initial == null ? '' : initial.amount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    contributorController.dispose();
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialIncome != null;

    return AppSheet(
      title: isEditing ? 'Edit Income' : 'Add Income',
      helpTitle: 'Income Entry',
      helpLines: const [
        'Use this for actual monthly income added by one person or the other.',
        'Contributor can be a partner name, and title can be salary, freelance, refund, or bonus.',
      ],
      child: Column(
        children: [
          TextField(
            controller: contributorController,
            decoration: const InputDecoration(labelText: 'Who added it?'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (contributorController.text.trim().isEmpty ||
                    titleController.text.trim().isEmpty ||
                    amount == null ||
                    amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter contributor, title, and an amount greater than zero.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  IncomeEntry(
                    id: widget.initialIncome?.id ?? makeId(),
                    contributor: contributorController.text.trim(),
                    title: titleController.text.trim(),
                    amount: amount,
                    date: widget.initialIncome?.date ?? DateTime.now(),
                  ),
                );
              },
              child: Text(isEditing ? 'Save Changes' : 'Save Income'),
            ),
          ),
        ],
      ),
    );
  }
}
