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
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
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
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
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
  });

  final String id;
  final String name;
  final double amount;
  final String category;
  final String schedule;
  final DateTime? endDate;
  final String? lastAppliedMonth;

  RecurringAllocation copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? schedule,
    DateTime? endDate,
    String? lastAppliedMonth,
  }) {
    return RecurringAllocation(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      schedule: schedule ?? this.schedule,
      endDate: endDate ?? this.endDate,
      lastAppliedMonth: lastAppliedMonth ?? this.lastAppliedMonth,
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
    };
  }

  factory RecurringAllocation.fromJson(Map<String, dynamic> json) {
    return RecurringAllocation(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: json['category'] as String? ?? 'Other',
      schedule: json['schedule'] as String? ?? 'Monthly',
      endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
      lastAppliedMonth: json['lastAppliedMonth'] as String?,
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
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      targetDate: DateTime.tryParse(json['targetDate'] as String? ?? '') ??
          DateTime.now(),
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
    required this.categoryBudgets,
    required this.incomeEntries,
    required this.expenses,
    required this.recurringAllocations,
    required this.goals,
  });

  double monthlyIncome;
  double monthlyTax;
  double monthlySpendingGoal;
  final Map<String, double> categoryBudgets;
  final List<IncomeEntry> incomeEntries;
  final List<Expense> expenses;
  final List<RecurringAllocation> recurringAllocations;
  final List<FinancialGoal> goals;

  double get totalSpent => expenses.fold(0, (sum, item) => sum + item.amount);

  double get totalIncomeEntries =>
      incomeEntries.fold(0, (sum, item) => sum + item.amount);

  double get totalRecurring =>
      recurringAllocations.fold(0, (sum, item) => sum + item.amount);

  double get totalGoalSaved =>
      goals.fold(0, (sum, item) => sum + item.currentAmount);

  bool get hasBudgetSetup =>
      monthlyIncome > 0 || monthlyTax > 0 || monthlySpendingGoal > 0;

  Map<String, dynamic> toJson() {
    return {
      'monthlyIncome': monthlyIncome,
      'monthlyTax': monthlyTax,
      'monthlySpendingGoal': monthlySpendingGoal,
      'categoryBudgets': categoryBudgets,
      'incomeEntries': incomeEntries.map((item) => item.toJson()).toList(),
      'expenses': expenses.map((item) => item.toJson()).toList(),
      'recurringAllocations':
          recurringAllocations.map((item) => item.toJson()).toList(),
      'goals': goals.map((item) => item.toJson()).toList(),
    };
  }

  factory BudgetData.fromJson(Map<String, dynamic> json) {
    final expensesJson = json['expenses'] as List<dynamic>? ?? const [];
    final recurringJson =
        json['recurringAllocations'] as List<dynamic>? ?? const [];
    final goalsJson = json['goals'] as List<dynamic>? ?? const [];
    final incomeJson = json['incomeEntries'] as List<dynamic>? ?? const [];
    final categoryBudgetsJson =
        Map<String, dynamic>.from(json['categoryBudgets'] as Map? ?? const {});

    return BudgetData(
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
      monthlyTax: (json['monthlyTax'] as num?)?.toDouble() ?? 0,
      monthlySpendingGoal: (json['monthlySpendingGoal'] as num?)?.toDouble() ?? 0,
      categoryBudgets: categoryBudgetsJson.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      incomeEntries: incomeJson
          .map((item) => IncomeEntry.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      expenses: expensesJson
          .map((item) => Expense.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      recurringAllocations: recurringJson
          .map(
            (item) =>
                RecurringAllocation.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      goals: goalsJson
          .map(
            (item) =>
                FinancialGoal.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}

String makeId() => DateTime.now().microsecondsSinceEpoch.toString();
