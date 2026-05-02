import 'package:flutter/material.dart';

import '../../../models/budget_models.dart';
import '../../shared/widgets/help_widgets.dart';

class OnboardingResult {
  OnboardingResult({
    required this.monthlyIncome,
    required this.monthlyTax,
    required this.monthlyGoal,
    required this.firstRecurring,
    required this.firstGoal,
  });

  final double monthlyIncome;
  final double monthlyTax;
  final double monthlyGoal;
  final RecurringAllocation? firstRecurring;
  final FinancialGoal? firstGoal;
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController pageController = PageController();
  final incomeController = TextEditingController();
  final taxController = TextEditingController();
  final goalController = TextEditingController();
  final recurringNameController = TextEditingController();
  final recurringAmountController = TextEditingController();
  final goalNameController = TextEditingController();
  final goalTargetController = TextEditingController();

  int currentPage = 0;
  String recurringCategory = 'Investing';

  @override
  void dispose() {
    pageController.dispose();
    incomeController.dispose();
    taxController.dispose();
    goalController.dispose();
    recurringNameController.dispose();
    recurringAmountController.dispose();
    goalNameController.dispose();
    goalTargetController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goNext() {
    if (currentPage == 0) {
      final income = double.tryParse(incomeController.text);
      final tax = double.tryParse(taxController.text);
      final goal = double.tryParse(goalController.text);
      if (income == null ||
          income <= 0 ||
          tax == null ||
          tax < 0 ||
          goal == null ||
          goal <= 0) {
        _showError('Enter valid income, tax, and monthly goal values.');
        return;
      }
      if (tax > income) {
        _showError('Tax cannot be higher than income.');
        return;
      }
    }

    if (currentPage < 2) {
      setState(() => currentPage += 1);
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final recurringAmount = double.tryParse(recurringAmountController.text);
    final goalTarget = double.tryParse(goalTargetController.text);
    final hasRecurringName = recurringNameController.text.trim().isNotEmpty;
    final hasRecurringAmount = recurringAmountController.text.trim().isNotEmpty;
    final hasGoalName = goalNameController.text.trim().isNotEmpty;
    final hasGoalAmount = goalTargetController.text.trim().isNotEmpty;

    if ((hasRecurringName || hasRecurringAmount) &&
        (!hasRecurringName ||
            recurringAmount == null ||
            recurringAmount <= 0)) {
      _showError(
        'Complete the recurring allocation with a valid positive amount or leave it blank.',
      );
      return;
    }

    if ((hasGoalName || hasGoalAmount) &&
        (!hasGoalName || goalTarget == null || goalTarget <= 0)) {
      _showError(
        'Complete the first goal with a valid positive target or leave it blank.',
      );
      return;
    }

    Navigator.of(context).pop(
      OnboardingResult(
        monthlyIncome: double.parse(incomeController.text),
        monthlyTax: double.parse(taxController.text),
        monthlyGoal: double.parse(goalController.text),
        firstRecurring:
            recurringNameController.text.trim().isEmpty ||
                recurringAmount == null
            ? null
            : RecurringAllocation(
                id: makeId(),
                name: recurringNameController.text.trim(),
                amount: recurringAmount,
                category: recurringCategory,
                schedule: 'Monthly',
                endDate: null,
              ),
        firstGoal: goalNameController.text.trim().isEmpty || goalTarget == null
            ? null
            : FinancialGoal(
                id: makeId(),
                name: goalNameController.text.trim(),
                targetAmount: goalTarget,
                currentAmount: 0,
                targetDate: DateTime(DateTime.now().year + 1, 12, 31),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _StepShell(
        eyebrow: 'Step 1',
        title: 'Set your core budget',
        subtitle:
            'These numbers unlock the dashboard and every spending calculation.',
        child: Column(
          children: [
            TextField(
              controller: incomeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Monthly income'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: taxController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Monthly tax'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: goalController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly spending goal',
              ),
            ),
          ],
        ),
      ),
      _StepShell(
        eyebrow: 'Step 2',
        title: 'Optional automatic transfer',
        subtitle:
            'Seed your plan with one recurring move like investing or charity.',
        child: Column(
          children: [
            TextField(
              controller: recurringNameController,
              decoration: const InputDecoration(labelText: 'Allocation name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recurringAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: recurringCategory,
              items: const ['Investing', 'Charity', 'Savings', 'Bills', 'Other']
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => recurringCategory = value!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
      ),
      _StepShell(
        eyebrow: 'Step 3',
        title: 'Optional first goal',
        subtitle: 'Add one dream to make the plan feel personal from day one.',
        child: Column(
          children: [
            TextField(
              controller: goalNameController,
              decoration: const InputDecoration(labelText: 'Goal name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: goalTargetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Target amount'),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Welcome to Budget Flow',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const HelpIconButton(
                    title: 'Onboarding Help',
                    lines: [
                      'Step 1 is required because the app needs your core budget numbers.',
                      'Steps 2 and 3 are optional shortcuts to seed your first recurring item and first goal.',
                    ],
                  ),
                  if (currentPage > 0)
                    TextButton(
                      onPressed: () {
                        if (currentPage < 2) {
                          setState(() => currentPage = 2);
                          pageController.jumpToPage(2);
                        } else {
                          _goNext();
                        }
                      },
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: index <= currentPage
                            ? const Color(0xFF0F766E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _goNext,
                  child: Text(currentPage == 2 ? 'Finish Setup' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF115E59), Color(0xFFE76F51)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: child,
        ),
      ],
    );
  }
}
