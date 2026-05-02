import '../models/budget_models.dart';

BudgetData buildSeedBudgetData() {
  return BudgetData(
    monthlyIncome: 0,
    monthlyTax: 0,
    monthlySpendingGoal: 0,
    budgetCycleStartDay: 1,
    categoryBudgets: {},
    incomeEntries: [],
    expenses: [],
    recurringAllocations: [],
    goals: [],
    goalContributions: [],
    stockHoldings: [],
    portfolioSnapshots: [],
  );
}
