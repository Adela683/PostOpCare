import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Sign In / Login
  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up
  Future<UserCredential> signUp(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
