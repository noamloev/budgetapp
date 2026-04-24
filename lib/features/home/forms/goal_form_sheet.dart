import 'package:flutter/material.dart';

import '../../../models/budget_models.dart';
import '../../shared/widgets/app_sheet.dart';

class GoalFormSheet extends StatefulWidget {
  const GoalFormSheet({
    super.key,
    this.initialGoal,
  });

  final FinancialGoal? initialGoal;

  @override
  State<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<GoalFormSheet> {
  late final TextEditingController nameController;
  late final TextEditingController targetController;
  late final TextEditingController savedController;
  late final TextEditingController yearController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGoal;
    nameController = TextEditingController(text: initial?.name ?? '');
    targetController = TextEditingController(
      text: initial == null ? '' : initial.targetAmount.toStringAsFixed(0),
    );
    savedController = TextEditingController(
      text: initial == null ? '0' : initial.currentAmount.toStringAsFixed(0),
    );
    yearController = TextEditingController(
      text: (initial?.targetDate.year ?? 2027).toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    targetController.dispose();
    savedController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialGoal != null;

    return AppSheet(
      title: isEditing ? 'Edit Goal' : 'Add Goal',
      helpTitle: 'Goals',
      helpLines: const [
        'Goals turn budgeting into progress toward something meaningful.',
        'You can edit the target later and add contributions over time.',
      ],
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Goal name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: targetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Target amount'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: savedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Already saved'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: yearController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Target year'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final target = double.tryParse(targetController.text);
                final saved = double.tryParse(savedController.text);
                final year = int.tryParse(yearController.text);
                if (target == null ||
                    target <= 0 ||
                    saved == null ||
                    saved < 0 ||
                    year == null ||
                    year < DateTime.now().year ||
                    nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a valid goal, positive target, non-negative saved amount, and a future year.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  context,
                  FinancialGoal(
                    id: widget.initialGoal?.id ?? makeId(),
                    name: nameController.text.trim(),
                    targetAmount: target,
                    currentAmount: saved,
                    targetDate: DateTime(year, 12, 31),
                  ),
                );
              },
              child: Text(isEditing ? 'Save Changes' : 'Save Goal'),
            ),
          ),
        ],
      ),
    );
  }
}
