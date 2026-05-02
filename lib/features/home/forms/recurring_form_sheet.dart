import 'package:flutter/material.dart';

import '../../../app/app_localizations.dart';
import '../../../models/budget_models.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets/app_sheet.dart';

class RecurringFormSheet extends StatefulWidget {
  const RecurringFormSheet({super.key, this.initialItem, required this.goals});

  final RecurringAllocation? initialItem;
  final List<FinancialGoal> goals;

  @override
  State<RecurringFormSheet> createState() => _RecurringFormSheetState();
}

class _RecurringFormSheetState extends State<RecurringFormSheet> {
  late final TextEditingController nameController;
  late final TextEditingController amountController;
  String category = 'Investing';
  String schedule = 'Monthly';
  String? linkedGoalId;
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
    linkedGoalId = (initial?.linkedGoalId?.isNotEmpty ?? false)
        ? initial?.linkedGoalId
        : null;
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
    final t = context.t;
    final isEditing = widget.initialItem != null;

    return AppSheet(
      title: isEditing
          ? (t.isHebrew ? 'ערוך הוצאה אוטומטית' : 'Edit Automatic Spending')
          : (t.isHebrew ? 'הוסף הוצאה אוטומטית' : 'Add Automatic Spending'),
      helpTitle: t.isHebrew ? 'הוצאה אוטומטית' : 'Automatic Spending',
      helpLines: [
        t.isHebrew
            ? 'השתמש בהקצאות חוזרות לכסף שיוצא או עובר בכל חודש.'
            : 'Use recurring allocations for money intentionally moved every month.',
        t.isHebrew
            ? 'אפשר גם לקשר את ההקצאה ליעד כדי לעדכן את החיסכון שם אוטומטית.'
            : 'You can also link the allocation to a goal so the goal updates automatically.',
      ],
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: t.text('name')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.text('amount')),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: category,
            items:
                const [
                      'Investing',
                      'Charity',
                      'Bills',
                      'Savings',
                      'Loan',
                      'Other',
                    ]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(t.recurringCategoryLabel(item)),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => category = value!),
            decoration: InputDecoration(labelText: t.text('category')),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: schedule,
            items: const ['Monthly', 'Weekly', 'Yearly']
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(t.scheduleLabel(item)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => schedule = value!),
            decoration: InputDecoration(labelText: t.text('schedule')),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: linkedGoalId,
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(t.text('no_goal_link')),
              ),
              ...widget.goals.map(
                (goal) => DropdownMenuItem<String?>(
                  value: goal.id,
                  child: Text(goal.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => linkedGoalId = value),
            decoration: InputDecoration(labelText: t.text('goal_link')),
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
                    onChanged: (value) =>
                        setState(() => selectedMonth = value!),
                    decoration: InputDecoration(
                      labelText: t.text('until_month'),
                    ),
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
                    decoration: InputDecoration(
                      labelText: t.text('until_year'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t.isHebrew
                    ? 'תשלומי ההלוואה יסומנו עד ${formatMonthYear(DateTime(selectedYear, selectedMonth))}.'
                    : 'Loan payments will be marked until ${formatMonthYear(DateTime(selectedYear, selectedMonth))}.',
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
                if (amount == null ||
                    amount <= 0 ||
                    nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.isHebrew
                            ? 'הכנס שם הקצאה וסכום גדול מאפס.'
                            : 'Enter an allocation name and an amount greater than zero.',
                      ),
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
                    linkedGoalId: linkedGoalId,
                  ),
                );
              },
              child: Text(
                isEditing ? t.saveChanges : t.text('save_allocation'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
