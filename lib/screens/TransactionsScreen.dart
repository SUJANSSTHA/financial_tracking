
import 'package:flutter/material.dart';
import '../models/TransactionModelwithJSONserialization.dart';
import '../widgets/add_transaction_dialog.dart';


class TransactionsScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onAddTransaction;
  final Function(String) onDeleteTransaction;

  const TransactionsScreen({super.key, 
    required this.transactions,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return Dismissible(
            key: Key(transaction.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              onDeleteTransaction(transaction.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Transaction deleted')),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.isIncome ? Colors.green : Colors.red,
                  child: Icon(
                    transaction.isIncome ? Icons.add : Icons.remove,
                    color: Colors.white,
                  ),
                ),
                title: Text(transaction.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.category),
                    Text(
                      '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: Text(
                  '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionDialog(onAddTransaction: onAddTransaction);
      },
    );
  }
}

