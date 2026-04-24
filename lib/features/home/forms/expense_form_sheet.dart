import 'package:flutter/material.dart';

import '../../../models/budget_models.dart';
import '../../shared/expense_categories.dart';
import '../../shared/widgets/app_sheet.dart';

class ExpenseFormSheet extends StatefulWidget {
  const ExpenseFormSheet({
    super.key,
    this.initialExpense,
  });

  final Expense? initialExpense;

  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  late final TextEditingController titleController;
  late final TextEditingController amountController;
  late final TextEditingController noteController;
  String category = ExpenseCategory.food.label;
  String paymentMethod = 'Card';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialExpense;
    titleController = TextEditingController(text: initial?.title ?? '');
    amountController = TextEditingController(
      text: initial == null ? '' : initial.amount.toStringAsFixed(0),
    );
    noteController = TextEditingController(text: initial?.note ?? '');
    category = initial?.category ?? ExpenseCategory.food.label;
    paymentMethod = initial?.paymentMethod ?? 'Card';
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExpense != null;

    return AppSheet(
      title: isEditing ? 'Edit Payment' : 'Add Payment',
      helpTitle: 'Payments',
      helpLines: const [
        'Use this form to log a purchase or update one you already saved.',
        'Category helps reports. Payment method helps you understand how money moved.',
      ],
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'What did you pay for?'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: category,
            items: ExpenseCategory.values
                .map((item) => DropdownMenuItem(value: item.label, child: Text(item.label)))
                .toList(),
            onChanged: (value) => setState(() => category = value!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: paymentMethod,
            items: const ['Card', 'Cash', 'Bank Transfer', 'Digital Wallet']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => paymentMethod = value!),
            decoration: const InputDecoration(labelText: 'Payment Method'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0 || titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a payment name and an amount greater than zero.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  Expense(
                    id: widget.initialExpense?.id ?? makeId(),
                    title: titleController.text.trim(),
                    amount: amount,
                    category: category,
                    paymentMethod: paymentMethod,
                    account: 'Shared Budget',
                    note: noteController.text.trim(),
                    date: widget.initialExpense?.date ?? DateTime.now(),
                  ),
                );
              },
              child: Text(isEditing ? 'Save Changes' : 'Save Payment'),
            ),
          ),
        ],
      ),
    );
  }
}
