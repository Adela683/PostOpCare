import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postopcare/data/models/pacient.dart';
export 'package:postopcare/data/models/pacient.dart';

class PatientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId;

  PatientRepository({required String userId}) : _userId = userId;

  CollectionReference<Map<String, dynamic>> get _patientsCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('pacients');
  }

  Future<void> addPacient(Pacient pacient) async {
    try {
      await _patientsCollection.add(pacient.toMap());
    } catch (e) {
      throw Exception('Failed to add pacient: $e');
    }
  }

  Future<List<Pacient>> getAllPacients() async {
    try {
      final snapshot = await _patientsCollection.get();
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // asigură id-ul documentului
            return Pacient.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get patients: $e');
    }
  }

  Future<void> updatePacient(Pacient pacient) async {
    try {
      await _patientsCollection.doc(pacient.id).update(pacient.toMap());
    } catch (e) {
      throw Exception('Failed to update pacient: $e');
    }
  }

  Future<void> deletePacient(String id) async {
    try {
      await _patientsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete pacient: $e');
    }
  }
}
