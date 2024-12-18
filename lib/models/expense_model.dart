import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String userId; // User who added the expense
  final double amount; // Expense amount
  final String description; // Description of the expense
  final DateTime createdAt; // Timestamp of when the expense was added
  final String groupId; // The group ID the expense belongs to
  final String? userName;

  Expense({
    required this.userId,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.groupId,
    required this.userName,
  });

  // Convert Expense to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'groupId': groupId,
      'userName': userName,
    };
  }

  // Convert Firestore Document to Expense Model
  factory Expense.fromMap(Map<String, dynamic> data) {
    return Expense(
      userId: data['userId'] ?? '', // Fallback to an empty string if null
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0, // Convert to double and fallback to 0.0
      description: data['description'] ?? 'No description', // Default description
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // Fallback to current time
      groupId: data['groupId'] ?? '', // Fallback to an empty string if null
      userName: data['userName'] ??  'unknown',
    );
  }
}
