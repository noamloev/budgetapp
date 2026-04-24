import 'package:flutter/material.dart';

import '../../../models/budget_models.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets/app_sheet.dart';

class RecurringFormSheet extends StatefulWidget {
  const RecurringFormSheet({
    super.key,
    this.initialItem,
  });

  final RecurringAllocation? initialItem;

  @override
  State<RecurringFormSheet> createState() => _RecurringFormSheetState();
}

class _RecurringFormSheetState extends State<RecurringFormSheet> {
  late final TextEditingController nameController;
  late final TextEditingController amountController;
  String category = 'Investing';
  String schedule = 'Monthly';
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialItem;
    nameController = TextEditingController(text: initial?.name ?? '');
    amountController = TextEditingController(
      text: initial == null ? '' : initial.amount.toStringAsFixed(0),
    );
    category = initial?.category ?? 'Investing';
    schedule = initial?.schedule ?? 'Monthly';
    selectedMonth = initial?.endDate?.month ?? DateTime.now().month;
    selectedYear = initial?.endDate?.year ?? DateTime.now().year;
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;

    return AppSheet(
      title: isEditing ? 'Edit Automatic Spending' : 'Add Automatic Spending',
      helpTitle: 'Automatic Spending',
      helpLines: const [
        'Use recurring allocations for money that is intentionally moved every month.',
        'Examples: investing, charity, savings, rent, subscriptions, or fixed bills.',
      ],
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
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
            items: const ['Investing', 'Charity', 'Bills', 'Savings', 'Loan', 'Other']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => category = value!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: schedule,
            items: const ['Monthly', 'Weekly', 'Yearly']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => schedule = value!),
            decoration: const InputDecoration(labelText: 'Schedule'),
          ),
          if (category == 'Loan') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    items: List.generate(
                      12,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text((index + 1).toString().padLeft(2, '0')),
                      ),
                    ),
                    onChanged: (value) => setState(() => selectedMonth = value!),
                    decoration: const InputDecoration(labelText: 'Until month'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    items: List.generate(
                      10,
                      (index) => DropdownMenuItem(
                        value: DateTime.now().year + index,
                        child: Text('${DateTime.now().year + index}'),
                      ),
                    ),
                    onChanged: (value) => setState(() => selectedYear = value!),
                    decoration: const InputDecoration(labelText: 'Until year'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Loan payments will be marked until ${formatMonthYear(DateTime(selectedYear, selectedMonth))}.',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0 || nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter an allocation name and an amount greater than zero.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  RecurringAllocation(
                    id: widget.initialItem?.id ?? makeId(),
                    name: nameController.text.trim(),
                    amount: amount,
                    category: category,
                    schedule: schedule,
                    endDate: category == 'Loan'
                        ? DateTime(selectedYear, selectedMonth)
                        : null,
                    lastAppliedMonth: widget.initialItem?.lastAppliedMonth,
                  ),
                );
              },
              child: Text(isEditing ? 'Save Changes' : 'Save Allocation'),
            ),
          ),
        ],
      ),
    );
  }
}
