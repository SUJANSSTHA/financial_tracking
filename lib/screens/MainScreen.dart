// Main Screen with Bottom Navigation and Enhanced Budget Operations
import 'package:flutter/material.dart';

import '../models/BudgetModelwithJSONserialization.dart';
import 'BudgetScreen.dart';
import 'DashboardScreen.dart';
import '../SharedPreferencesManager.dart';
import '../models/TransactionModelwithJSONserialization.dart';
import 'TransactionsScreen.dart';
import 'statusScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Transaction> transactions = [];
  List<Budget> budgets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    try {
      final loadedTransactions = await PreferencesManager.loadTransactions();
      final loadedBudgets = await PreferencesManager.loadBudgets();

      setState(() {
        transactions = loadedTransactions;
        budgets = loadedBudgets;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addTransaction(Transaction transaction) async {
    setState(() {
      transactions.insert(0, transaction);
      // Update budget spent amount
      int budgetIndex =
          budgets.indexWhere((b) => b.category == transaction.category);
      if (budgetIndex != -1 && !transaction.isIncome) {
        budgets[budgetIndex] = Budget(
          category: budgets[budgetIndex].category,
          limit: budgets[budgetIndex].limit,
          spent: budgets[budgetIndex].spent + transaction.amount,
        );
      }
    });

    // Save to SharedPreferences
    await PreferencesManager.saveTransactions(transactions);
    await PreferencesManager.saveBudgets(budgets);
  }

  void _deleteTransaction(String id) async {
    Transaction transaction = transactions.firstWhere((t) => t.id == id);

    setState(() {
      transactions.removeWhere((t) => t.id == id);

      // Update budget spent amount
      int budgetIndex =
          budgets.indexWhere((b) => b.category == transaction.category);
      if (budgetIndex != -1 && !transaction.isIncome) {
        budgets[budgetIndex] = Budget(
          category: budgets[budgetIndex].category,
          limit: budgets[budgetIndex].limit,
          spent: budgets[budgetIndex].spent - transaction.amount,
        );
      }
    });

    // Save to SharedPreferences
    await PreferencesManager.saveTransactions(transactions);
    await PreferencesManager.saveBudgets(budgets);
  }

  void _updateBudget(Budget updatedBudget) async {
    setState(() {
      int index =
          budgets.indexWhere((b) => b.category == updatedBudget.category);
      if (index != -1) {
        // If category name changed, update related transactions
        String oldCategory = budgets[index].category;
        if (oldCategory != updatedBudget.category) {
          // Update transactions with the old category to use the new category name
          for (int i = 0; i < transactions.length; i++) {
            if (transactions[i].category == oldCategory) {
              transactions[i] = Transaction(
                id: transactions[i].id,
                title: transactions[i].title,
                amount: transactions[i].amount,
                category: updatedBudget.category,
                date: transactions[i].date,
                isIncome: transactions[i].isIncome,
              );
            }
          }
        }
        budgets[index] = updatedBudget;
      }
    });

    // Save to SharedPreferences
    await PreferencesManager.saveBudgets(budgets);
    await PreferencesManager.saveTransactions(transactions);
  }

  // NEW: Add budget function
  void _addBudget(Budget newBudget) async {
    setState(() {
      // Check if budget with same category already exists
      int existingIndex = budgets.indexWhere((b) => b.category == newBudget.category);
      if (existingIndex == -1) {
        budgets.add(newBudget);
      } else {
        // Show error or update existing budget
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget for "${newBudget.category}" already exists!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    });

    // Save to SharedPreferences
    await PreferencesManager.saveBudgets(budgets);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Budget for "${newBudget.category}" added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // NEW: Delete budget function
  void _deleteBudget(String category) async {
    setState(() {
      budgets.removeWhere((budget) => budget.category == category);
      
      // Optionally, you might want to handle transactions with this category
      // You can either:
      // 1. Remove transactions with this category
      // 2. Move them to "Uncategorized"
      // 3. Keep them as is (current implementation)
      
      // Option 2: Move to "Uncategorized"
      for (int i = 0; i < transactions.length; i++) {
        if (transactions[i].category == category) {
          transactions[i] = Transaction(
            id: transactions[i].id,
            title: transactions[i].title,
            amount: transactions[i].amount,
            category: 'Uncategorized',
            date: transactions[i].date,
            isIncome: transactions[i].isIncome,
          );
        }
      }
    });

    // Save to SharedPreferences
    await PreferencesManager.saveBudgets(budgets);
    await PreferencesManager.saveTransactions(transactions);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Budget for "$category" deleted successfully!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _clearAllData() async {
    await PreferencesManager.clearAllData();
    setState(() {
      transactions.clear();
      budgets = [
        Budget(category: 'Food', limit: 500.00, spent: 0.00),
        Budget(category: 'Transportation', limit: 200.00, spent: 0.00),
        Budget(category: 'Entertainment', limit: 300.00, spent: 0.00),
        Budget(category: 'Shopping', limit: 400.00, spent: 0.00),
      ];
    });
    await PreferencesManager.saveBudgets(budgets);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    List<Widget> pages = [
      DashboardScreen(transactions: transactions, onClearData: _clearAllData),
      TransactionsScreen(
        transactions: transactions,
        onAddTransaction: _addTransaction,
        onDeleteTransaction: _deleteTransaction,
      ),
      BudgetScreen(
        budgets: budgets, 
        onUpdateBudget: _updateBudget,
        onAddBudget: _addBudget,        // NEW: Added missing parameter
        onDeleteBudget: _deleteBudget,  // NEW: Added missing parameter
      ),
      StatsScreen(transactions: transactions),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}