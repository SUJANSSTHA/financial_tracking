// Add Transaction Dialog (unchanged)
import 'package:flutter/material.dart';

import '../models/TransactionModelwithJSONserialization.dart';

class AddTransactionDialog extends StatefulWidget {
  final Function(Transaction) onAddTransaction;

  const AddTransactionDialog({super.key, required this.onAddTransaction});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  String _selectedCategory = 'Food';
  bool _isIncome = false;
  bool _isCustomCategory = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills',
    'Healthcare',
    'Education',
    'Income',
    'Other',
    'Custom',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Transaction'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                    _isCustomCategory = newValue == 'Custom';
                    if (!_isCustomCategory) {
                      _customCategoryController.clear();
                    }
                  });
                },
              ),
              // Custom Category Input Field
              if (_isCustomCategory)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: TextFormField(
                    controller: _customCategoryController,
                    decoration: InputDecoration(
                      labelText: 'Custom Category Name',
                      hintText: 'Enter your custom category',
                      prefixIcon: Icon(Icons.edit),
                    ),
                    validator: (value) {
                      if (_isCustomCategory && (value == null || value.trim().isEmpty)) {
                        return 'Please enter a custom category name';
                      }
                      return null;
                    },
                  ),
                ),
              SwitchListTile(
                title: Text('Income'),
                value: _isIncome,
                onChanged: (bool value) {
                  setState(() {
                    _isIncome = value;
                  });
                },
              ),
              ListTile(
                title: Text('Date'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              String finalCategory = _isCustomCategory 
                  ? _customCategoryController.text.trim()
                  : _selectedCategory;
              
              final transaction = Transaction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text,
                amount: double.parse(_amountController.text),
                category: finalCategory,
                date: _selectedDate,
                isIncome: _isIncome,
              );
              widget.onAddTransaction(transaction);
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }
}
