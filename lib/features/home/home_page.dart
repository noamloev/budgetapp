import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/app_localizations.dart';
import '../../data/budget_engine.dart';
import '../../data/budget_storage.dart';
import '../../data/seed_data.dart';
import '../../data/supabase_budget_repository.dart';
import '../../models/budget_models.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import 'forms/budget_settings_sheet.dart';
import 'onboarding/onboarding_flow.dart';
import 'sections/dashboard_screen.dart';
import 'sections/expenses_screen.dart';
import 'sections/planning_screen.dart';
import 'sections/stocks_screen.dart';

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
      data = syncBudgetData(
        remote ?? local ?? buildSeedBudgetData(),
        DateTime.now(),
      );
      isLoading = false;
    });

    await _persist();

    if ((remote == null || !data.hasBudgetSetup) &&
        !hasSeenOnboarding &&
        mounted) {
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
      data = syncBudgetData(remote, DateTime.now());
    });
    await localStorage.saveBudget(data);
  }

  Future<void> _persist() async {
    syncBudgetData(data, DateTime.now());
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
    final index = data.recurringAllocations.indexWhere(
      (existing) => existing.id == item.id,
    );
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
      data.goalContributions.removeWhere(
        (contribution) => contribution.goalId == id,
      );
      for (var i = 0; i < data.recurringAllocations.length; i++) {
        final item = data.recurringAllocations[i];
        if (item.linkedGoalId == id) {
          data.recurringAllocations[i] = item.copyWith(linkedGoalId: '');
        }
      }
    });
    _persist();
  }

  void _contributeToGoal(
    String goalId,
    double amount, {
    String source = 'manual',
  }) {
    final index = data.goals.indexWhere((goal) => goal.id == goalId);
    if (index == -1) {
      return;
    }
    setState(() {
      final goal = data.goals[index];
      data.goals[index] = goal.copyWith(
        currentAmount: goal.currentAmount + amount,
      );
      data.goalContributions.insert(
        0,
        GoalContribution(
          id: makeId(),
          goalId: goalId,
          amount: amount,
          date: DateTime.now(),
          source: source,
        ),
      );
    });
    _persist();
  }

  void _upsertStock(StockHolding holding) {
    final index = data.stockHoldings.indexWhere(
      (item) => item.id == holding.id,
    );
    setState(() {
      if (index == -1) {
        data.stockHoldings.insert(0, holding);
      } else {
        data.stockHoldings[index] = holding;
      }
    });
    _persist();
  }

  void _deleteStock(String id) {
    setState(() {
      data.stockHoldings.removeWhere((item) => item.id == id);
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
    final t = context.t;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
        onUpdateBudgetSettings:
            ({
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
      StocksScreen(
        holdings: data.stockHoldings,
        onUpsertStock: _upsertStock,
        onDeleteStock: _deleteStock,
      ),
      HistoryScreen(data: data),
      SettingsScreen(
        cycleStartDay: data.budgetCycleStartDay,
        onUpdateCycleStartDay: (day) {
          setState(() {
            data.budgetCycleStartDay = day;
          });
          _persist();
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            onPressed: _refreshFromCloud,
            icon: const Icon(Icons.cloud_sync_rounded),
            tooltip: t.text('refresh_from_cloud'),
          ),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
            tooltip: t.text('log_out'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_rounded),
            label: t.text('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_rounded),
            label: t.text('expenses'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_graph_rounded),
            label: t.text('plan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.candlestick_chart_rounded),
            label: t.text('stocks'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_rounded),
            label: t.text('history'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_rounded),
            label: t.text('settings'),
          ),
        ],
      ),
    );
  }
}
