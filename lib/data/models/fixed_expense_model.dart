class FixedExpenseModel {
  final String id;
  final String name;
  final String? description;
  final int amount;
  final String category;
  final bool isActive;
  final String recurrenceType; // MONTHLY, WEEKLY, DAILY
  final DateTime createdAt;
  final DateTime updatedAt;

  FixedExpenseModel({
    required this.id,
    required this.name,
    this.description,
    required this.amount,
    required this.category,
    required this.isActive,
    required this.recurrenceType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FixedExpenseModel.fromJson(Map<String, dynamic> json) {
    return FixedExpenseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toInt(),
      category: json['category'] as String,
      isActive: json['is_active'] as bool? ?? true,
      recurrenceType: json['recurrence_type'] as String? ?? 'MONTHLY',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'description': description,
      'amount': amount,
      'category': category,
      'is_active': isActive,
      'recurrence_type': recurrenceType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  FixedExpenseModel copyWith({
    String? id,
    String? name,
    String? description,
    int? amount,
    String? category,
    bool? isActive,
    String? recurrenceType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FixedExpenseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
