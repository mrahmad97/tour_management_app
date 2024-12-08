import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String userId; // User who added the expense
  final double amount; // Expense amount
  final String description; // Description of the expense
  final DateTime createdAt; // Timestamp of when the expense was added
  final String groupId; // The group ID the expense belongs to

  Expense({
    required this.userId,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.groupId, // Add groupId to the constructor
  });

  // Convert Expense to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'groupId': groupId, // Add groupId to the map
    };
  }

  // Convert Firestore Document to Expense Model
  factory Expense.fromMap(Map<String, dynamic> data) {
    return Expense(
      userId: data['userId'],
      amount: data['amount'],
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      groupId: data['groupId'], // Parse groupId from data
    );
  }
}
