import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postopcare/data/models/surgery.dart';
import 'package:postopcare/data/repositories/appointment_repository/appointment_repository.dart';
export 'package:postopcare/data/models/surgery.dart';

class SurgeryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId;
  final String _pacientId;

  SurgeryRepository({required String userId, required String pacientId})
    : _userId = userId,
      _pacientId = pacientId;

  CollectionReference<Map<String, dynamic>> get _surgeriesCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('pacients')
        .doc(_pacientId)
        .collection('surgeries');
  }

  Future<List<Surgery>> getSurgeries() async {
    try {
      final snapshot = await _surgeriesCollection.get();

      List<Surgery> surgeries = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Instanțiem repository-ul pentru appointments pentru această operație
        final appointmentRepo = AppointmentRepository(
          userId: _userId,
          pacientId: _pacientId,
          surgeryId: doc.id,
        );

        // Preluăm controalele asociate
        final appointments = await appointmentRepo.getAppointments();

        // Citim lista de poze din Firestore (dacă există)
        final photosUrls = <String>[];
        if (data.containsKey('photosUrls') && data['photosUrls'] is List) {
          photosUrls.addAll(List<String>.from(data['photosUrls']));
        }

        final surgery = Surgery.fromMap(
          data,
          appointments: appointments,
          photosUrls: photosUrls,
        );
        surgeries.add(surgery);
      }
      return surgeries;
    } catch (e) {
      throw Exception('Failed to get surgeries: $e');
    }
  }

  Future<void> addSurgery(Surgery surgery) async {
    try {
      await _surgeriesCollection.add(surgery.toMap());
    } catch (e) {
      throw Exception('Failed to add surgery: $e');
    }
  }

  Future<void> updateSurgery(Surgery surgery) async {
    try {
      await _surgeriesCollection.doc(surgery.id).update(surgery.toMap());
    } catch (e) {
      throw Exception('Failed to update surgery: $e');
    }
  }

  Future<void> deleteSurgery(String id) async {
    try {
      await _surgeriesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete surgery: $e');
    }
  }

  Future<DocumentReference> addSurgeryReturnDocRef(Surgery surgery) async {
    try {
      final docRef = await _surgeriesCollection.add(surgery.toMap());
      return docRef;
    } catch (e) {
      throw Exception('Failed to add surgery: $e');
    }
  }
}
