import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tour_management_app/models/user_model.dart';

Future<List<UserModel>> fetchAllUsers() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    List<UserModel> users = snapshot.docs.map((doc) {
      return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();

    // Print user details for debugging
    for (var user in users) {
      print(user);
    }

    return users;
  } catch (e) {
    print("Error fetching users: $e");
    return [];
  }
}
