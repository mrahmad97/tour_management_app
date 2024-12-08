import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';

// Function to create a group in Firestore
Future<void> createGroup({
  required String groupName,
  required String description,
  required String createdBy,
  required List<String> memberIds,
}) async {
  try {
    // Generate a unique groupId using Firestore's doc() method
    final groupId = FirebaseFirestore.instance.collection('groups').doc().id;

    // Create a new group using the Group model
    Group newGroup = Group(
      id: groupId,
      name: groupName,
      description: description,
      createdBy: createdBy,
      members: memberIds,
    );

    // Add the group to Firestore using the generated groupId
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .set(newGroup.toMap());

    print("Group created successfully!");
  } catch (e) {
    print("Error creating group: $e");
  }
}
