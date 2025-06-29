// Budget Model with JSON serialization
class Budget {
  final String category;
  final double limit;
  final double spent;

  Budget({required this.category, required this.limit, required this.spent});

  double get remaining => limit - spent;
  double get percentage => spent / limit;

  // Convert Budget to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'limit': limit,
      'spent': spent,
    };
  }

  // Create Budget from JSON
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['category'],
      limit: json['limit'].toDouble(),
      spent: json['spent'].toDouble(),
    );
  }
}
