import 'package:cloud_firestore/cloud_firestore.dart';

class Pacient {
  final String id;
  final String nume;
  final int varsta;
  final String diagnostic;

  // Constructor
  Pacient({
    required this.id,
    required this.nume,
    required this.varsta,
    required this.diagnostic,
  });

  // Convertire Pacient într-un Map pentru Firestore
  Map<String, dynamic> toMap() {
    return {
      'nume': nume,
      'varsta': varsta,
      'diagnostic': diagnostic,
    };
  }

  // Creare Pacient dintr-un DocumentSnapshot din Firestore
  factory Pacient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Pacient(
      id: doc.id,
      nume: data['nume'] ?? '',
      varsta: data['varsta'] ?? 0,
      diagnostic: data['diagnostic'] ?? '',
    );
  }

  // Reprezentare pentru debugging
  @override
  String toString() {
    return 'Pacient(id: $id, nume: $nume, varsta: $varsta, diagnostic: $diagnostic)';
  }
}
