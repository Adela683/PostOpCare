// lib/repositories/user_repository/user_data_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postopcare/data/models/user.dart';

class UserDataRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserData(AppUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<AppUser?> getUserData(String uid) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return AppUser.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }
}
