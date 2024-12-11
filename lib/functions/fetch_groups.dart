import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tour_management_app/models/group_model.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/providers/user_provider.dart';
import 'package:flutter/material.dart';

Future<List<Group>> fetchGroupsCreatedByUser(BuildContext context) async {
  try {
    final currentUserId = Provider.of<UserProvider>(context, listen: false).user?.uid;

    if (currentUserId == null) {
      throw Exception("User ID is not available.");
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('createdBy', isEqualTo: currentUserId) // Fetch groups where createdBy matches the current user ID
        .get();

    final groups = querySnapshot.docs.map((doc) {
      return Group.fromMap(doc.data());
    }).toList();

    return groups;
  } catch (e) {
    print("Error fetching groups: $e");
    return [];
  }
}
