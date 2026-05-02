class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.account,
    required this.note,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final String paymentMethod;
  final String account;
  final String note;
  final DateTime date;

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? paymentMethod,
    String? account,
    String? note,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      account: account ?? this.account,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'account': account,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? 'Other',
      paymentMethod: json['paymentMethod'] as String? ?? 'Card',
      account: json['account'] as String? ?? 'Main Account',
      note: json['note'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class IncomeEntry {
  IncomeEntry({
    required this.id,
    required this.contributor,
    required this.title,
    required this.amount,
    required this.date,
  });

  final String id;
  final String contributor;
  final String title;
  final double amount;
  final DateTime date;

  IncomeEntry copyWith({
    String? id,
    String? contributor,
    String? title,
    double? amount,
    DateTime? date,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      contributor: contributor ?? this.contributor,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contributor': contributor,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory IncomeEntry.fromJson(Map<String, dynamic> json) {
    return IncomeEntry(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      contributor: json['contributor'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class RecurringAllocation {
  RecurringAllocation({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.schedule,
    this.endDate,
    this.lastAppliedMonth,
    this.linkedGoalId,
  });

  final String id;
  final String name;
  final double amount;
  final String category;
  final String schedule;
  final DateTime? endDate;
  final String? lastAppliedMonth;
  final String? linkedGoalId;

  RecurringAllocation copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? schedule,
    DateTime? endDate,
    String? lastAppliedMonth,
    String? linkedGoalId,
  }) {
    return RecurringAllocation(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      schedule: schedule ?? this.schedule,
      endDate: endDate ?? this.endDate,
      lastAppliedMonth: lastAppliedMonth ?? this.lastAppliedMonth,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'schedule': schedule,
      'endDate': endDate?.toIso8601String(),
      'lastAppliedMonth': lastAppliedMonth,
      'linkedGoalId': linkedGoalId,
    };
  }

  factory RecurringAllocation.fromJson(Map<String, dynamic> json) {
    return RecurringAllocation(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? 'Other',
      schedule: json['schedule'] as String? ?? 'Monthly',
      endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
      lastAppliedMonth: json['lastAppliedMonth'] as String?,
      linkedGoalId: json['linkedGoalId'] as String?,
    );
  }
}

class FinancialGoal {
  FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
    };
  }

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      targetDate:
          DateTime.tryParse(json['targetDate'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class GoalContribution {
  GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    required this.source,
    this.recurringAllocationId,
  });

  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String source;
  final String? recurringAllocationId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'date': date.toIso8601String(),
      'source': source,
      'recurringAllocationId': recurringAllocationId,
    };
  }

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      goalId: json['goalId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      source: json['source'] as String? ?? 'manual',
      recurringAllocationId: json['recurringAllocationId'] as String?,
    );
  }
}

class StockHolding {
  StockHolding({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.buyPrice,
    required this.currentPrice,
  });

  final String id;
  final String symbol;
  final String companyName;
  final double quantity;
  final double buyPrice;
  final double currentPrice;

  double get investedAmount => quantity * buyPrice;
  double get currentValue => quantity * currentPrice;
  double get gainLoss => currentValue - investedAmount;
  double get gainLossPercent =>
      investedAmount == 0 ? 0 : (gainLoss / investedAmount) * 100;

  StockHolding copyWith({
    String? id,
    String? symbol,
    String? companyName,
    double? quantity,
    double? buyPrice,
    double? currentPrice,
  }) {
    return StockHolding(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      currentPrice: currentPrice ?? this.currentPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'companyName': companyName,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'currentPrice': currentPrice,
    };
  }

  factory StockHolding.fromJson(Map<String, dynamic> json) {
    return StockHolding(
      id:
          json['id'] as String? ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      symbol: json['symbol'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      buyPrice: (json['buyPrice'] as num?)?.toDouble() ?? 0,
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PortfolioSnapshot {
  PortfolioSnapshot({
    required this.cycleKey,
    required this.cycleStart,
    required this.cycleEndExclusive,
    required this.openingBalance,
    required this.netBaseIncome,
    required this.additionalIncome,
    required this.spent,
    required this.recurringSpent,
    required this.goalContributionTotal,
    required this.closingBalance,
  });

  final String cycleKey;
  final DateTime cycleStart;
  final DateTime cycleEndExclusive;
  final double openingBalance;
  final double netBaseIncome;
  final double additionalIncome;
  final double spent;
  final double recurringSpent;
  final double goalContributionTotal;
  final double closingBalance;

  Map<String, dynamic> toJson() {
    return {
      'cycleKey': cycleKey,
      'cycleStart': cycleStart.toIso8601String(),
      'cycleEndExclusive': cycleEndExclusive.toIso8601String(),
      'openingBalance': openingBalance,
      'netBaseIncome': netBaseIncome,
      'additionalIncome': additionalIncome,
      'spent': spent,
      'recurringSpent': recurringSpent,
      'goalContributionTotal': goalContributionTotal,
      'closingBalance': closingBalance,
    };
  }

  factory PortfolioSnapshot.fromJson(Map<String, dynamic> json) {
    return PortfolioSnapshot(
      cycleKey: json['cycleKey'] as String? ?? '',
      cycleStart:
          DateTime.tryParse(json['cycleStart'] as String? ?? '') ??
          DateTime.now(),
      cycleEndExclusive:
          DateTime.tryParse(json['cycleEndExclusive'] as String? ?? '') ??
          DateTime.now(),
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0,
      netBaseIncome: (json['netBaseIncome'] as num?)?.toDouble() ?? 0,
      additionalIncome: (json['additionalIncome'] as num?)?.toDouble() ?? 0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0,
      recurringSpent: (json['recurringSpent'] as num?)?.toDouble() ?? 0,
      goalContributionTotal:
          (json['goalContributionTotal'] as num?)?.toDouble() ?? 0,
      closingBalance: (json['closingBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class BudgetSettingsResult {
  BudgetSettingsResult({
    required this.monthlyIncome,
    required this.monthlyTax,
    required this.monthlyGoal,
  });

  final double monthlyIncome;
  final double monthlyTax;
  final double monthlyGoal;
}

class BudgetData {
  BudgetData({
    required this.monthlyIncome,
    required this.monthlyTax,
    required this.monthlySpendingGoal,
    required this.budgetCycleStartDay,
    required this.categoryBudgets,
    required this.incomeEntries,
    required this.expenses,
    required this.recurringAllocations,
    required this.goals,
    required this.goalContributions,
    required this.stockHoldings,
    required this.portfolioSnapshots,
  });

  double monthlyIncome;
  double monthlyTax;
  double monthlySpendingGoal;
  int budgetCycleStartDay;
  final Map<String, double> categoryBudgets;
  final List<IncomeEntry> incomeEntries;
  final List<Expense> expenses;
  final List<RecurringAllocation> recurringAllocations;
  final List<FinancialGoal> goals;
  final List<GoalContribution> goalContributions;
  final List<StockHolding> stockHoldings;
  final List<PortfolioSnapshot> portfolioSnapshots;

  double get totalSpent => expenses.fold(0, (sum, item) => sum + item.amount);

  double get totalIncomeEntries =>
      incomeEntries.fold(0, (sum, item) => sum + item.amount);

  double get totalRecurring =>
      recurringAllocations.fold(0, (sum, item) => sum + item.amount);

  double get totalGoalSaved =>
      goals.fold(0, (sum, item) => sum + item.currentAmount);

  double get totalStockValue =>
      stockHoldings.fold(0, (sum, item) => sum + item.currentValue);

  double get totalStockInvested =>
      stockHoldings.fold(0, (sum, item) => sum + item.investedAmount);

  double get totalStockGainLoss =>
      stockHoldings.fold(0, (sum, item) => sum + item.gainLoss);

  bool get hasBudgetSetup =>
      monthlyIncome > 0 || monthlyTax > 0 || monthlySpendingGoal > 0;

  Map<String, dynamic> toJson() {
    return {
      'monthlyIncome': monthlyIncome,
      'monthlyTax': monthlyTax,
      'monthlySpendingGoal': monthlySpendingGoal,
      'budgetCycleStartDay': budgetCycleStartDay,
      'categoryBudgets': categoryBudgets,
      'incomeEntries': incomeEntries.map((item) => item.toJson()).toList(),
      'expenses': expenses.map((item) => item.toJson()).toList(),
      'recurringAllocations': recurringAllocations
          .map((item) => item.toJson())
          .toList(),
      'goals': goals.map((item) => item.toJson()).toList(),
      'goalContributions': goalContributions
          .map((item) => item.toJson())
          .toList(),
      'stockHoldings': stockHoldings.map((item) => item.toJson()).toList(),
      'portfolioSnapshots': portfolioSnapshots
          .map((item) => item.toJson())
          .toList(),
    };
  }

  factory BudgetData.fromJson(Map<String, dynamic> json) {
    final expensesJson = json['expenses'] as List<dynamic>? ?? const [];
    final recurringJson =
        json['recurringAllocations'] as List<dynamic>? ?? const [];
    final goalsJson = json['goals'] as List<dynamic>? ?? const [];
    final incomeJson = json['incomeEntries'] as List<dynamic>? ?? const [];
    final goalContributionJson =
        json['goalContributions'] as List<dynamic>? ?? const [];
    final stockHoldingsJson =
        json['stockHoldings'] as List<dynamic>? ?? const [];
    final portfolioSnapshotsJson =
        json['portfolioSnapshots'] as List<dynamic>? ?? const [];
    final categoryBudgetsJson = Map<String, dynamic>.from(
      json['categoryBudgets'] as Map? ?? const {},
    );

    return BudgetData(
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
      monthlyTax: (json['monthlyTax'] as num?)?.toDouble() ?? 0,
      monthlySpendingGoal:
          (json['monthlySpendingGoal'] as num?)?.toDouble() ?? 0,
      budgetCycleStartDay: (json['budgetCycleStartDay'] as num?)?.toInt() ?? 1,
      categoryBudgets: categoryBudgetsJson.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      incomeEntries: incomeJson
          .map(
            (item) =>
                IncomeEntry.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      expenses: expensesJson
          .map(
            (item) => Expense.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      recurringAllocations: recurringJson
          .map(
            (item) => RecurringAllocation.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      goals: goalsJson
          .map(
            (item) =>
                FinancialGoal.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      goalContributions: goalContributionJson
          .map(
            (item) => GoalContribution.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      stockHoldings: stockHoldingsJson
          .map(
            (item) =>
                StockHolding.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      portfolioSnapshots: portfolioSnapshotsJson
          .map(
            (item) => PortfolioSnapshot.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

String makeId() => DateTime.now().microsecondsSinceEpoch.toString();
