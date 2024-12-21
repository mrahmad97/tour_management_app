import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tour_management_app/constants/colors.dart';
import '../../../models/expense_model.dart';

class ExpenseSummaryScreen extends StatefulWidget {
  final String? groupId;

  const ExpenseSummaryScreen({Key? key, this.groupId}) : super(key: key);

  @override
  _ExpenseSummaryScreenState createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
  late double totalAmount = 0.0;
  late int numberOfMembers = 0;

  // Fetch expenses and calculate
  Future<void> _fetchAndCalculateExpenses() async {
    try {
      // Fetch expenses for the group
      final expensesSnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('groupId', isEqualTo: widget.groupId)
          .get();

      // Calculate total amount of expenses
      totalAmount = expensesSnapshot.docs.fold(0.0, (sum, doc) {
        final expense = Expense.fromMap(doc.data());
        return sum + expense.amount;
      });

      // Get the number of members in the group
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        numberOfMembers = groupSnapshot.data()?['members'].length ?? 0;
      }

      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAndCalculateExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final amountPerMember =
        numberOfMembers > 0 ? totalAmount / numberOfMembers : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Expense Summary',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
      ),
      backgroundColor: AppColors.surfaceColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Expenses: \$${totalAmount.toStringAsFixed(2)}'),
                Text('Number of Members: $numberOfMembers'),
                Text(
                    'Amount per Member: \$${amountPerMember.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenses')
                  .where('groupId', isEqualTo: widget.groupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No expenses found.'));
                }

                // Display list of expenses
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final expense = Expense.fromMap(snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0,0,0,8),
                      child: Material(
                        elevation: 4,
                        child: ListTile(
                          tileColor: AppColors.cardBackgroundColor,
                          title: Text(
                            expense.userName ?? 'Unknown',
                            style: TextStyle(color: AppColors.primaryTextColor),
                          ),
                          subtitle: Text(
                              'Description: ${expense.description} \n Time: ${DateFormat('HH:mm').format(expense.createdAt)} \n Date: ${DateFormat('dd:MM:yy').format(expense.createdAt)}'),
                          trailing: Text('\$${expense.amount.toStringAsFixed(2)}',style: TextStyle(color: AppColors.primaryColor,fontWeight: FontWeight.bold,fontSize: 14),),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
