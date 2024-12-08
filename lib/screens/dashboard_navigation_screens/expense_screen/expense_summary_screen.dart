import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/expense_model.dart';

class ExpenseSummaryScreen extends StatefulWidget {
  final String? groupId;

  const ExpenseSummaryScreen({Key? key,this.groupId}) : super(key: key);

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

      // Print the number of expenses fetched
      print('Number of expenses: ${expensesSnapshot.docs.length}');

      // Calculate total amount of expenses
      totalAmount = expensesSnapshot.docs.fold(0.0, (sum, doc) {
        final expense = Expense.fromMap(doc.data());
        print('Fetched expense: ${expense.amount}'); // Print each expense's amount
        return sum + expense.amount;
      });

      // Print total amount after calculation
      print('Total expenses calculated: $totalAmount');

      // Get the number of members in the group (you would fetch this from the group's data)
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (groupSnapshot.exists) {
        numberOfMembers = groupSnapshot.data()?['members'].length ?? 0;
      }

      // Print number of members in the group
      print('Number of members in the group: $numberOfMembers');

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
    final amountPerMember = totalAmount / numberOfMembers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Summary'),
      ),
      body: Column(
        children: [
          Text('Total Expenses: \$${totalAmount.toStringAsFixed(2)}'),
          Text('Number of Members: $numberOfMembers'),
          Text('Amount per Member: \$${amountPerMember.toStringAsFixed(2)}'),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('members') // Assuming the group has a collection of members
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No members found.'));
                }

                // List members and how much they owe
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final member = snapshot.data!.docs[index];
                    final memberName = member['name'];
                    return ListTile(
                      title: Text(memberName),
                      subtitle: Text('Amount owed: \$${amountPerMember.toStringAsFixed(2)}'),
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
