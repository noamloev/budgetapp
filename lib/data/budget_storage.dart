import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_models.dart';

class BudgetStorage {
  static const _budgetKey = 'budget_data_v1';
  static const _onboardingKey = 'budget_onboarding_seen_v1';

  Future<BudgetData?> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_budgetKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return BudgetData.fromJson(decoded);
  }

  Future<void> saveBudget(BudgetData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetKey, jsonEncode(data.toJson()));
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}
