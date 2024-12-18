import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/providers/user_provider.dart';
import 'package:tour_management_app/screens/dashboard_navigation_screens/expense_screen/expense_summary_screen.dart';
import 'package:tour_management_app/screens/global_components/custom_text_field.dart';
import 'package:tour_management_app/screens/global_components/responsive_widget.dart';

import '../../../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? groupId;

  const AddExpenseScreen({super.key, this.groupId});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();


  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number.';
    }

    final numValue = int.tryParse(value);

    if (numValue == null) {
      return 'Please enter a valid number.';
    }

    if (numValue <= 100) {
      return 'Number must be greater than 100.';
    }

    if (numValue >= 100000) {
      return 'Number must be less than 100,000.';
    }

    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter description.';
    }

    return null;
  }

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
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        groupId: widget.groupId!,
        userName: user.displayName,
      );

      _descriptionController.clear();
      _amountController.clear();


      try {
        await FirebaseFirestore.instance
            .collection('expenses')
            .add(expense.toMap());
        ResponsiveWidget.isLargeScreen(context) ? null : Navigator.pop(context); // Go back after adding the expense
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Expense',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.surfaceColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle('Amount'),
              CustomTextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                validation: _validateNumber,
                onSaved: (value) {
                  amount = double.parse(value!);
                },
                hintKey: 'Add amount',
              ),
              _buildTitle('Description'),
              CustomTextFormField(
                controller: _descriptionController,
                validation: _validateDescription,
                onSaved: (value) {
                  description = value!;
                },
                hintKey: 'Add description',
              ),
              SizedBox(height: 20),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.surfaceColor,
                          backgroundColor: AppColors.primaryColor),
                      onPressed: _addExpense,
                      child: Text('Add Expense'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.surfaceColor,
                            backgroundColor: AppColors.primaryColor),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ExpenseSummaryScreen(groupId: widget.groupId),
                          ));
                        },
                        child: Text('Get Each User Expense'))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
    );
  }
}
