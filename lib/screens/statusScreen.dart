
// Stats Screen (unchanged)

// Stats Screen
import 'package:flutter/material.dart';

import '../models/TransactionModelwithJSONserialization.dart';


class StatsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const StatsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryTotals = {};
    
    for (var transaction in transactions) {
      if (!transaction.isIncome) {
        categoryTotals[transaction.category] = 
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    double totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending by Category',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    if (totalExpenses > 0)
                      ...categoryTotals.entries.map((entry) {
                        double percentage = entry.value / totalExpenses;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text('\Rs.${entry.value.toStringAsFixed(2)}'),
                                ],
                              ),
                              SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue[400]!,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${(percentage * 100).toStringAsFixed(1)}%',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      })
                    else
                      Text('No expenses recorded yet'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildSummaryRow('Total Transactions', transactions.length.toString()),
                    _buildSummaryRow('Total Income', '\Rs.${transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount).toStringAsFixed(2)}'),
                    _buildSummaryRow('Total Expenses', '\Rs.${totalExpenses.toStringAsFixed(2)}'),
                    _buildSummaryRow('Average Transaction', '\Rs.${(transactions.isNotEmpty ? transactions.fold(0.0, (sum, t) => sum + t.amount) / transactions.length : 0).toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}