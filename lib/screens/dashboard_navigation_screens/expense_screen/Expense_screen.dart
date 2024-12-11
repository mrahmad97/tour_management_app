import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/providers/user_provider.dart';
import 'package:tour_management_app/screens/dashboard_navigation_screens/expense_screen/expense_summary_screen.dart';

import '../../../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? groupId;

  const AddExpenseScreen({super.key, this.groupId});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late double amount;
  late String description;

  // Add Expense to Firebase
  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = Provider.of<UserProvider>(context, listen: false).user!;

      final expense = Expense(
        userId: user.uid,
        amount: amount,
        description: description,
        createdAt: DateTime.now(),
        groupId: widget.groupId!
      );

      try {
        await FirebaseFirestore.instance
            .collection('expenses')
            .add(expense.toMap());
        Navigator.pop(context); // Go back after adding the expense
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an amount.';
                  }
                  return null;
                },
                onSaved: (value) {
                  amount = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  description = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addExpense,
                child: Text('Add Expense'),
              ),
              ElevatedButton(onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExpenseSummaryScreen(groupId: widget.groupId),));
              }, child: Text('Get Each User Expense'))
            ],
          ),
        ),
      ),
    );
  }
}
