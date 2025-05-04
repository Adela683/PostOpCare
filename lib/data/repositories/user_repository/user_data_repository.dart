import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postopcare/data/models/user.dart';

class UserDataRepository {
  final FirebaseFirestore _firestore;

  UserDataRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _collection = 'users';

  // create
  Future<void> createUser(AppUser user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(user.toMap());
    } catch (e) {
      print('[ERROR] createUser: $e');
      rethrow;
    }
  }

  // fetch
  Future<AppUser?> fetchUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!);
    } catch (e) {
      print('[ERROR] fetchUser: $e');
      return null;
    }
  }

  // update
  Future<void> updateUser(AppUser user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      print('[ERROR] updateUser: $e');
      rethrow;
    }
  }

  // delete
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collection).doc(uid).delete();
    } catch (e) {
      print('[ERROR] deleteUser: $e');
      rethrow;
    }
  }
}
