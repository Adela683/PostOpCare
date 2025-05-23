import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postopcare/data/models/pacient.dart';
export 'package:postopcare/data/models/pacient.dart';

class PatientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId;

  PatientRepository({required String userId}) : _userId = userId;

  // Colecția de pacienți a utilizatorului curent
  CollectionReference get _pacientsCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('pacients');
  }

  // Adăugare pacient
  Future<void> addPacient(Pacient pacient) async {
    try {
      await _pacientsCollection.add(pacient.toMap());
    } catch (e) {
      throw Exception('Failed to add pacient: $e');
    }
  }

  // Obține toți pacienții
  Future<List<Pacient>> getAllPacients() async {
    try {
      final snapshot = await _pacientsCollection.get();
      return snapshot.docs.map((doc) => Pacient.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load pacients: $e');
    }
  }

  // Actualizare pacient
  Future<void> updatePacient(Pacient pacient) async {
    try {
      await _pacientsCollection.doc(pacient.id).update(pacient.toMap());
    } catch (e) {
      throw Exception('Failed to update pacient: $e');
    }
  }

  // Ștergere pacient
  Future<void> deletePacient(String pacientId) async {
    try {
      await _pacientsCollection.doc(pacientId).delete();
    } catch (e) {
      throw Exception('Failed to delete pacient: $e');
    }
  }
}
