import 'package:flutter/material.dart';

import '../../../app/app_localizations.dart';
import '../../shared/widgets/app_sheet.dart';

class GoalContributionSheet extends StatefulWidget {
  const GoalContributionSheet({super.key});

  @override
  State<GoalContributionSheet> createState() => _GoalContributionSheetState();
}

class _GoalContributionSheetState extends State<GoalContributionSheet> {
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AppSheet(
      title: t.text('contribute'),
      helpTitle: t.isHebrew ? 'הפקדה ליעד' : 'Goal Contribution',
      helpLines: [
        t.isHebrew
            ? 'השתמש בזה כדי להוסיף כסף שנחסך ליעד בלי לשנות את היעד עצמו.'
            : 'Use this to add more saved money to a goal without changing its target.',
      ],
      child: Column(
        children: [
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: t.text('contribution_amount'),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        t.isHebrew
                            ? 'הכנס סכום גדול מאפס.'
                            : 'Enter an amount greater than zero.',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, amount);
              },
              child: Text(t.text('contribute')),
            ),
          ),
        ],
      ),
    );
  }
}
