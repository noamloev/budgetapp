import 'package:flutter/material.dart';

import '../../../app/app_localizations.dart';
import '../../../models/budget_models.dart';
import '../../shared/widgets/app_sheet.dart';

class IncomeFormSheet extends StatefulWidget {
  const IncomeFormSheet({super.key, this.initialIncome});

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
    contributorController = TextEditingController(
      text: initial?.contributor ?? '',
    );
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
    final t = context.t;
    final isEditing = widget.initialIncome != null;

    return AppSheet(
      title: isEditing
          ? (t.isHebrew ? 'ערוך הכנסה' : 'Edit Income')
          : t.text('add_income'),
      helpTitle: t.isHebrew ? 'רישום הכנסה' : 'Income Entry',
      helpLines: [
        t.isHebrew
            ? 'השתמש בזה להכנסה חודשית אמיתית שנכנסה לחשבון.'
            : 'Use this for actual monthly income added by one person or the other.',
      ],
      child: Column(
        children: [
          TextField(
            controller: contributorController,
            decoration: InputDecoration(labelText: t.text('who_added_it')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: t.text('title')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.text('amount')),
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
                    SnackBar(
                      content: Text(
                        t.isHebrew
                            ? 'הכנס מי הוסיף, כותרת וסכום גדול מאפס.'
                            : 'Enter contributor, title, and an amount greater than zero.',
                      ),
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
              child: Text(isEditing ? t.saveChanges : t.text('save_income')),
            ),
          ),
        ],
      ),
    );
  }
}
