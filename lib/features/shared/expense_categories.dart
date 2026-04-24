import 'package:flutter/material.dart';

enum ExpenseCategory {
  food('Food', Icons.restaurant_rounded),
  transport('Transport', Icons.directions_bus_rounded),
  shopping('Shopping', Icons.shopping_bag_rounded),
  bills('Bills', Icons.receipt_rounded),
  health('Health', Icons.favorite_rounded),
  entertainment('Entertainment', Icons.movie_rounded),
  charity('Charity', Icons.volunteer_activism_rounded),
  investing('Investing', Icons.trending_up_rounded);

  const ExpenseCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

IconData categoryIconFor(String category) {
  return ExpenseCategory.values
      .firstWhere(
        (item) => item.label == category,
        orElse: () => ExpenseCategory.shopping,
      )
      .icon;
}
