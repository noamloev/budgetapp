import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/budget_models.dart';

class SupabaseBudgetRepository {
  SupabaseBudgetRepository(this.client);

  final SupabaseClient client;
  static const table = 'budget_documents';

  Future<BudgetData?> loadBudget() async {
    final user = client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final response = await client
        .from(table)
        .select('payload')
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final payload = response['payload'];
    if (payload is String) {
      return BudgetData.fromJson(jsonDecode(payload) as Map<String, dynamic>);
    }
    if (payload is Map<String, dynamic>) {
      return BudgetData.fromJson(payload);
    }
    return null;
  }

  Future<void> saveBudget(BudgetData data) async {
    final user = client.auth.currentUser;
    if (user == null) {
      return;
    }

    await client.from(table).upsert({
      'user_id': user.id,
      'payload': data.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
