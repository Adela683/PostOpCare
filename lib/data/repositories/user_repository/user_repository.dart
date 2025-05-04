import 'package:postopcare/data/models/user.dart';
import 'auth_repository.dart';
import 'user_data_repository.dart';
export 'auth_repository.dart';
export 'user_data_repository.dart';

class UserRepository {
  final AuthRepository _authRepo;
  final UserDataRepository _userDataRepo;

  UserRepository({
    required AuthRepository authRepository,
    required UserDataRepository userDataRepository,
  }) : _authRepo = authRepository,
       _userDataRepo = userDataRepository;

  // Register a new user (Auth + Firestore)
  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authRepo.signUp(email, password);

    final uid = credential.user!.uid;
    final username = _generateUsernameFromName(name);

    final user = AppUser(id: uid, name: name, email: email, username: username);

    await _userDataRepo.createUser(user);
    return user;
  }

  // Login + fetch user data (Auth + Firestore)
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _authRepo.signIn(email, password);
    final uid = credential.user!.uid;

    return await _userDataRepo.fetchUser(uid);
  }

  // Logout
  Future<void> logout() async {
    await _authRepo.signOut();
  }

  // Get current user info (from Firestore)
  Future<AppUser?> getCurrentUser() async {
    final user = _authRepo.currentUser;
    if (user == null) return null;
    return await _userDataRepo.fetchUser(user.uid);
  }

  // Delete account (optional)
  Future<void> deleteAccount() async {
    final user = _authRepo.currentUser;
    if (user != null) {
      await _userDataRepo.deleteUser(user.uid);
      await user.delete(); // delete from FirebaseAuth
    }
  }

  // Helper to convert name → username
  String _generateUsernameFromName(String name) {
    return name.toLowerCase().replaceAll(' ', '.');
  }
}
