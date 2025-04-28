class AppUser {
  String? id;  // Firebase user UID (this will be generated after user signs up or logs in)
  String name;
  String email;
  String username;

  // Constructor
  AppUser({
    this.id,  // UID will be assigned by Firebase Authentication
    required this.name,
    required this.email,
    required this.username,
  });

  // Convert User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
    };
  }

  // Create User from Map (when retrieving data from Firestore)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'], // The id is fetched from Firestore
      name: map['name'],
      email: map['email'],
      username: map['username'],
    );
  }

  // Optional: For debugging and printing User details
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, username: $username)';
  }
}
