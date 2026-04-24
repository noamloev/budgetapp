import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/budget_storage.dart';
import '../../data/seed_data.dart';
import '../../data/supabase_budget_repository.dart';
import '../../models/budget_models.dart';
import '../shared/widgets/help_widgets.dart';
import 'forms/budget_settings_sheet.dart';
import 'onboarding/onboarding_flow.dart';
import 'sections/dashboard_screen.dart';
import 'sections/expenses_screen.dart';
import 'sections/planning_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final BudgetStorage localStorage = BudgetStorage();
  late final SupabaseBudgetRepository cloudRepository;
  late BudgetData data;
  int selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cloudRepository = SupabaseBudgetRepository(Supabase.instance.client);
    data = buildSeedBudgetData();
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshFromCloud();
    }
  }

  Future<void> _loadData() async {
    final local = await localStorage.loadBudget();
    final hasSeenOnboarding = await localStorage.hasSeenOnboarding();
    final remote = await cloudRepository.loadBudget();

    if (!mounted) {
      return;
    }

    setState(() {
      data = remote ?? local ?? buildSeedBudgetData();
      isLoading = false;
    });

    if ((remote == null || !data.hasBudgetSetup) && !hasSeenOnboarding && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openOnboarding();
      });
    }
  }

  Future<void> _refreshFromCloud() async {
    final remote = await cloudRepository.loadBudget();
    if (remote == null || !mounted) {
      return;
    }
    setState(() {
      data = remote;
    });
    await localStorage.saveBudget(data);
  }

  Future<void> _persist() async {
    await localStorage.saveBudget(data);
    await cloudRepository.saveBudget(data);
  }

  void _upsertExpense(Expense expense) {
    final index = data.expenses.indexWhere((item) => item.id == expense.id);
    setState(() {
      if (index == -1) {
        data.expenses.insert(0, expense);
      } else {
        data.expenses[index] = expense;
      }
    });
    _persist();
  }

  void _deleteExpense(String id) {
    setState(() {
      data.expenses.removeWhere((item) => item.id == id);
    });
    _persist();
  }

  void _upsertIncome(IncomeEntry income) {
    final index = data.incomeEntries.indexWhere((item) => item.id == income.id);
    setState(() {
      if (index == -1) {
        data.incomeEntries.insert(0, income);
      } else {
        data.incomeEntries[index] = income;
      }
    });
    _persist();
  }

  void _deleteIncome(String id) {
    setState(() {
      data.incomeEntries.removeWhere((item) => item.id == id);
    });
    _persist();
  }

  void _upsertRecurring(RecurringAllocation item) {
    final index = data.recurringAllocations.indexWhere((existing) => existing.id == item.id);
    setState(() {
      if (index == -1) {
        data.recurringAllocations.add(item);
      } else {
        data.recurringAllocations[index] = item;
      }
    });
    _persist();
  }

  void _deleteRecurring(String id) {
    setState(() {
      data.recurringAllocations.removeWhere((item) => item.id == id);
    });
    _persist();
  }

  void _upsertGoal(FinancialGoal goal) {
    final index = data.goals.indexWhere((existing) => existing.id == goal.id);
    setState(() {
      if (index == -1) {
        data.goals.add(goal);
      } else {
        data.goals[index] = goal;
      }
    });
    _persist();
  }

  void _deleteGoal(String id) {
    setState(() {
      data.goals.removeWhere((goal) => goal.id == id);
    });
    _persist();
  }

  void _contributeToGoal(String goalId, double amount) {
    final index = data.goals.indexWhere((goal) => goal.id == goalId);
    if (index == -1) {
      return;
    }
    setState(() {
      final goal = data.goals[index];
      data.goals[index] = goal.copyWith(currentAmount: goal.currentAmount + amount);
    });
    _persist();
  }

  Future<void> _openBudgetSetup() async {
    final result = await showModalBottomSheet<BudgetSettingsResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetSettingsSheet(data: data),
    );

    if (result == null) {
      return;
    }

    setState(() {
      data.monthlyIncome = result.monthlyIncome;
      data.monthlyTax = result.monthlyTax;
      data.monthlySpendingGoal = result.monthlyGoal;
      selectedIndex = 0;
    });
    await localStorage.markOnboardingSeen();
    await _persist();
  }

  Future<void> _openOnboarding() async {
    final result = await Navigator.of(context).push<OnboardingResult>(
      MaterialPageRoute(builder: (_) => const OnboardingFlow()),
    );

    await localStorage.markOnboardingSeen();

    if (result == null) {
      return;
    }

    setState(() {
      data.monthlyIncome = result.monthlyIncome;
      data.monthlyTax = result.monthlyTax;
      data.monthlySpendingGoal = result.monthlyGoal;
      if (result.firstRecurring != null) {
        data.recurringAllocations.add(result.firstRecurring!);
      }
      if (result.firstGoal != null) {
        data.goals.add(result.firstGoal!);
      }
      selectedIndex = 0;
    });
    await _persist();
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      DashboardScreen(
        data: data,
        onStartSetup: _openBudgetSetup,
        onUpsertIncome: _upsertIncome,
        onDeleteIncome: _deleteIncome,
      ),
      ExpensesScreen(
        expenses: data.expenses,
        onUpsertExpense: _upsertExpense,
        onDeleteExpense: _deleteExpense,
      ),
      PlanningScreen(
        data: data,
        onUpdateBudgetSettings: ({
          required monthlyIncome,
          required monthlyTax,
          required monthlyGoal,
        }) {
          setState(() {
            data.monthlyIncome = monthlyIncome;
            data.monthlyTax = monthlyTax;
            data.monthlySpendingGoal = monthlyGoal;
          });
          _persist();
        },
        onUpdateCategoryBudgets: (budgets) {
          setState(() {
            data.categoryBudgets
              ..clear()
              ..addAll(budgets);
          });
          _persist();
        },
        onUpsertRecurring: _upsertRecurring,
        onDeleteRecurring: _deleteRecurring,
        onUpsertGoal: _upsertGoal,
        onDeleteGoal: _deleteGoal,
        onContributeToGoal: _contributeToGoal,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Flow'),
        actions: [
          const HelpIconButton(
            title: 'Shared Account Help',
            lines: [
              'This account is shared through Supabase. Log in with the same email and password on Android and Web.',
              'Changes are saved to the cloud, so both devices can work on the same budget.',
              'A different login has a completely different budget and cannot see this one at all.',
            ],
          ),
          IconButton(
            onPressed: _refreshFromCloud,
            icon: const Icon(Icons.cloud_sync_rounded),
            tooltip: 'Refresh from cloud',
          ),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: pages[selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_rounded),
            label: 'Plan',
          ),
        ],
      ),
    );
  }
}
