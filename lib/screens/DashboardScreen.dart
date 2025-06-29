
// // Dashboard Screen with Clear Data option
// import 'package:flutter/material.dart';
// import '../models/TransactionModelwithJSONserialization.dart';

// class DashboardScreen extends StatelessWidget {
//   final List<Transaction> transactions;
//   final VoidCallback onClearData;

//   const DashboardScreen({super.key, required this.transactions, required this.onClearData});

//   @override
//   Widget build(BuildContext context) {
//     double totalIncome = transactions
//         .where((t) => t.isIncome)
//         .fold(0.0, (sum, t) => sum + t.amount);
    
//     double totalExpense = transactions
//         .where((t) => !t.isIncome)
//         .fold(0.0, (sum, t) => sum + t.amount);
    
//     double balance = totalIncome - totalExpense;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Dashboard'),
//         backgroundColor: Colors.blue[600],
//         foregroundColor: Colors.white,
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'clear') {
//                 _showClearDataDialog(context);
//               }
//             },
//             itemBuilder: (BuildContext context) {
//               return [
//                 PopupMenuItem<String>(
//                   value: 'clear',
//                   child: Text('Clear All Data'),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Balance Card
//             Card(
//               elevation: 4,
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   gradient: LinearGradient(
//                     colors: [Colors.blue[600]!, Colors.blue[400]!],
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Total Balance',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       '\$${balance.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
            
//             // Income/Expense Row
//             Row(
//               children: [
//                 Expanded(
//                   child: Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Icon(Icons.arrow_upward, color: Colors.green, size: 32),
//                           Text('Income'),
//                           Text(
//                             '\$${totalIncome.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Icon(Icons.arrow_downward, color: Colors.red, size: 32),
//                           Text('Expenses'),
//                           Text(
//                             '\$${totalExpense.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
            
//             // Recent Transactions
//             Text(
//               'Recent Transactions',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 12),
//             ...transactions.take(5).map((transaction) => Card(
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: transaction.isIncome ? Colors.green : Colors.red,
//                   child: Icon(
//                     transaction.isIncome ? Icons.add : Icons.remove,
//                     color: Colors.white,
//                   ),
//                 ),
//                 title: Text(transaction.title),
//                 subtitle: Text(transaction.category),
//                 trailing: Text(
//                   '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: transaction.isIncome ? Colors.green : Colors.red,
//                   ),
//                 ),
//               ),
//             )),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showClearDataDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Clear All Data'),
//           content: Text('Are you sure you want to clear all transactions and reset budgets? This action cannot be undone.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 onClearData();
//                 Navigator.of(context).pop();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('All data cleared successfully')),
//                 );
//               },
//               child: Text('Clear', style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
// Dashboard Screen with Clear Data option
import 'package:flutter/material.dart';
import '../models/TransactionModelwithJSONserialization.dart';

class DashboardScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onClearData;

  const DashboardScreen({super.key, required this.transactions, required this.onClearData});

  @override
  Widget build(BuildContext context) {
    double totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    double totalExpense = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    double balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearDataDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Clear All Data'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rs.${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Income/Expense Row
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.green, size: 32),
                          Text('Income'),
                          Text(
                            'Rs.${totalIncome.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.red, size: 32),
                          Text('Expenses'),
                          Text(
                            'Rs.${totalExpense.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Recent Transactions
            Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...transactions.take(5).map((transaction) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.isIncome ? Colors.green : Colors.red,
                  child: Icon(
                    transaction.isIncome ? Icons.add : Icons.remove,
                    color: Colors.white,
                  ),
                ),
                title: Text(transaction.title),
                subtitle: Text(transaction.category),
                trailing: Text(
                  '${transaction.isIncome ? '+' : '-'}Rs.${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome ? Colors.green : Colors.red,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Data'),
          content: Text('Are you sure you want to clear all transactions and reset budgets? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onClearData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All data cleared successfully')),
                );
              },
              child: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}