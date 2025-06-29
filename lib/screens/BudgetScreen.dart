// Enhanced Dynamic Budget Screen with advanced functionality
import 'package:flutter/material.dart';

import '../models/BudgetModelwithJSONserialization.dart';

class BudgetScreen extends StatefulWidget {
  final List<Budget> budgets;
  final Function(Budget) onUpdateBudget;
  final Function(Budget) onAddBudget;
  final Function(String) onDeleteBudget;

  const BudgetScreen({
    super.key, 
    required this.budgets, 
    required this.onUpdateBudget,
    required this.onAddBudget,
    required this.onDeleteBudget,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with TickerProviderStateMixin {
  String _sortBy = 'category'; // category, spent, remaining, percentage
  bool _sortAscending = true;
  String _filterCategory = 'All';
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Budget> get filteredAndSortedBudgets {
    List<Budget> filtered = widget.budgets;
    
    // Filter by category
    if (_filterCategory != 'All') {
      filtered = filtered.where((budget) => budget.category == _filterCategory).toList();
    }
    
    // Sort budgets
    filtered.sort((a, b) {
      int result = 0;
      switch (_sortBy) {
        case 'category':
          result = a.category.compareTo(b.category);
          break;
        case 'spent':
          result = a.spent.compareTo(b.spent);
          break;
        case 'remaining':
          result = a.remaining.compareTo(b.remaining);
          break;
        case 'percentage':
          result = a.percentage.compareTo(b.percentage);
          break;
      }
      return _sortAscending ? result : -result;
    });
    
    return filtered;
  }

  Set<String> get availableCategories {
    return {'All', ...widget.budgets.map((b) => b.category)};
  }

  @override
  Widget build(BuildContext context) {
    final filteredBudgets = filteredAndSortedBudgets;
    final totalBudget = widget.budgets.fold(0.0, (sum, budget) => sum + budget.limit);
    final totalSpent = widget.budgets.fold(0.0, (sum, budget) => sum + budget.spent);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Management'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = true;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'category', child: Text('Sort by Category')),
              PopupMenuItem(value: 'spent', child: Text('Sort by Spent')),
              PopupMenuItem(value: 'remaining', child: Text('Sort by Remaining')),
              PopupMenuItem(value: 'percentage', child: Text('Sort by Percentage')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(totalBudget, totalSpent),
          
          // Filter and Controls
          _buildFilterControls(),
          
          // Budget List
          Expanded(
            child: filteredBudgets.isEmpty 
              ? _buildEmptyState() 
              : _buildBudgetList(filteredBudgets),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        backgroundColor: Colors.blue[600],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(double totalBudget, double totalSpent) {
    final overallPercentage = totalBudget > 0 ? totalSpent / totalBudget : 0.0;
    
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('Total Budget Overview', 
                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                   SizedBox(width: 8),
                Flexible(
                  child: Text('${widget.budgets.length} categories',
                       style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: overallPercentage.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                overallPercentage > 0.8 ? Colors.red : 
                overallPercentage > 0.6 ? Colors.orange : Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rs.${totalSpent.toStringAsFixed(2)} / Rs.${totalBudget.toStringAsFixed(2)}'),
                Text('${(overallPercentage * 100).toStringAsFixed(1)}%',
                     style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: DropdownButton<String>(
              value: _filterCategory,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  _filterCategory = newValue!;
                });
              },
              items: availableCategories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SizedBox(width: 16),
          Text('Sort: ${_sortBy.toUpperCase()}'),
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No budgets found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Tap the + button to add your first budget', 
               style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildBudgetList(List<Budget> budgets) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            final budget = budgets[index];
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
              )),
              child: _buildBudgetCard(budget, index),
            );
          },
        );
      },
    );
  }

  Widget _buildBudgetCard(Budget budget, int index) {
    final percentage = budget.percentage.clamp(0.0, 1.0);
    final isOverBudget = budget.remaining < 0;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showEditBudgetDialog(context, budget),
        onLongPress: () => _showDeleteConfirmation(context, budget),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isOverBudget ? Border.all(color: Colors.red, width: 2) : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        budget.category,
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: isOverBudget ? Colors.red : null,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (isOverBudget) 
                          Icon(Icons.warning, color: Colors.red, size: 20),
                        SizedBox(width: 4),
                        Text(
                          'Rs.${budget.spent.toStringAsFixed(2)} / Rs.${budget.limit.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14, 
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.edit, size: 16, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: percentage),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 1.0 ? Colors.red :
                        percentage > 0.8 ? Colors.red : 
                        percentage > 0.6 ? Colors.orange : Colors.green,
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining: Rs.${budget.remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: budget.remaining >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (percentage > 1.0 ? Colors.red :
                               percentage > 0.8 ? Colors.red : 
                               percentage > 0.6 ? Colors.orange : Colors.green).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(percentage * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: percentage > 1.0 ? Colors.red :
                                 percentage > 0.8 ? Colors.red : 
                                 percentage > 0.6 ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    final limitController = TextEditingController(text: budget.limit.toString());
    final spentController = TextEditingController(text: budget.spent.toString());
    final categoryController = TextEditingController(text: budget.category);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Budget'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: limitController,
                  decoration: InputDecoration(
                    labelText: 'Budget Limit',
                    border: OutlineInputBorder(),
                    prefixText: 'Rs.',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: spentController,
                  decoration: InputDecoration(
                    labelText: 'Amount Spent',
                    border: OutlineInputBorder(),
                    prefixText: 'Rs.',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newLimit = double.tryParse(limitController.text);
                final newSpent = double.tryParse(spentController.text);
                final newCategory = categoryController.text.trim();
                
                if (newLimit != null && newLimit > 0 && 
                    newSpent != null && newSpent >= 0 && 
                    newCategory.isNotEmpty) {
                  final updatedBudget = Budget(
                    category: newCategory,
                    limit: newLimit,
                    spent: newSpent,
                  );
                  widget.onUpdateBudget(updatedBudget);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final limitController = TextEditingController();
    final categoryController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: limitController,
                decoration: InputDecoration(
                  labelText: 'Budget Limit',
                  border: OutlineInputBorder(),
                  prefixText: 'Rs.',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final limit = double.tryParse(limitController.text);
                final category = categoryController.text.trim();
                
                if (limit != null && limit > 0 && category.isNotEmpty) {
                  final newBudget = Budget(
                    category: category,
                    limit: limit,
                    spent: 0.0,
                  );
                  widget.onAddBudget(newBudget);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add Budget'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Budget'),
          content: Text('Are you sure you want to delete the "${budget.category}" budget?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onDeleteBudget(budget.category);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}