import 'package:flutter/material.dart';

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
    return AppSheet(
      title: 'Add Contribution',
      helpTitle: 'Goal Contribution',
      helpLines: const [
        'Use this to add more saved money to a goal without changing its target.',
      ],
      child: Column(
        children: [
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Contribution amount'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter an amount greater than zero.')),
                  );
                  return;
                }
                Navigator.pop(context, amount);
              },
              child: const Text('Add Contribution'),
            ),
          ),
        ],
      ),
    );
  }
}
