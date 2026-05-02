import 'package:flutter/material.dart';

import '../../../app/app_localizations.dart';
import '../../../models/budget_models.dart';
import '../../shared/widgets/app_sheet.dart';

class BudgetSettingsSheet extends StatefulWidget {
  const BudgetSettingsSheet({super.key, required this.data});

  final BudgetData data;

  @override
  State<BudgetSettingsSheet> createState() => _BudgetSettingsSheetState();
}

class _BudgetSettingsSheetState extends State<BudgetSettingsSheet> {
  late final TextEditingController incomeController;
  late final TextEditingController taxController;
  late final TextEditingController goalController;

  @override
  void initState() {
    super.initState();
    incomeController = TextEditingController(
      text: widget.data.monthlyIncome.toStringAsFixed(0),
    );
    taxController = TextEditingController(
      text: widget.data.monthlyTax.toStringAsFixed(0),
    );
    goalController = TextEditingController(
      text: widget.data.monthlySpendingGoal.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    incomeController.dispose();
    taxController.dispose();
    goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AppSheet(
      title: t.isHebrew ? 'ערוך נתוני תקציב' : 'Edit Budget Numbers',
      helpTitle: t.isHebrew ? 'נתוני תקציב' : 'Budget Numbers',
      helpLines: [
        t.isHebrew
            ? 'הכנסה היא ההכנסה החודשית לפני ניכויים.'
            : 'Income is your gross monthly income.',
        t.isHebrew
            ? 'מס הוא מה שיורד לפני שהכסף זמין.'
            : 'Tax is what is removed before money is usable.',
        t.isHebrew
            ? 'יעד הוצאה חודשי הוא התקרה שאתה רוצה לשמור מתחתיה.'
            : 'Monthly spending goal is the limit you want to stay under.',
      ],
      child: Column(
        children: [
          TextField(
            controller: incomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.text('monthly_income')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: taxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.text('monthly_tax')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: goalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.text('monthly_spending_goal'),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final income = double.tryParse(incomeController.text);
                final tax = double.tryParse(taxController.text);
                final goal = double.tryParse(goalController.text);
                if (income == null ||
                    income <= 0 ||
                    tax == null ||
                    tax < 0 ||
                    goal == null ||
                    goal <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.isHebrew
                            ? 'הכנס מספרים חיוביים תקינים להכנסה וליעד החודשי.'
                            : 'Enter valid positive numbers for income and monthly goal.',
                      ),
                    ),
                  );
                  return;
                }
                if (tax > income) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.isHebrew
                            ? 'המס לא יכול להיות גבוה מההכנסה.'
                            : 'Tax cannot be higher than income.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  BudgetSettingsResult(
                    monthlyIncome: income,
                    monthlyTax: tax,
                    monthlyGoal: goal,
                  ),
                );
              },
              child: Text(t.text('save_numbers')),
            ),
          ),
        ],
      ),
    );
  }
}
