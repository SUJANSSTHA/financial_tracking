// SharedPreferences Manager
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/BudgetModelwithJSONserialization.dart';
import 'models/TransactionModelwithJSONserialization.dart';

class PreferencesManager {
  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';

  // Save transactions to SharedPreferences
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, jsonEncode(transactionsJson));
  }

  // Load transactions from SharedPreferences
  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsString = prefs.getString(_transactionsKey);

    if (transactionsString == null) {
      return [];
    }

    final transactionsJson = jsonDecode(transactionsString) as List;
    return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
  }

  // Save budgets to SharedPreferences
  static Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = budgets.map((b) => b.toJson()).toList();
    await prefs.setString(_budgetsKey, jsonEncode(budgetsJson));
  }

  // Load budgets from SharedPreferences
  static Future<List<Budget>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsString = prefs.getString(_budgetsKey);

    if (budgetsString == null) {
      // Return default budgets if none exist
      return [
        Budget(category: 'Food', limit: 500.00, spent: 0.00),
        Budget(category: 'Transportation', limit: 200.00, spent: 0.00),
        Budget(category: 'Entertainment', limit: 300.00, spent: 0.00),
        Budget(category: 'Shopping', limit: 400.00, spent: 0.00),
      ];
    }

    final budgetsJson = jsonDecode(budgetsString) as List;
    return budgetsJson.map((json) => Budget.fromJson(json)).toList();
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_budgetsKey);
  }
}
