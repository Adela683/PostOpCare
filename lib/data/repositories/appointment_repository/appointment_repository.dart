import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postopcare/data/models/appointment.dart';
export 'package:postopcare/data/models/appointment.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String userId;
  final String pacientId;
  final String surgeryId;

  AppointmentRepository({
    required this.userId,
    required this.pacientId,
    required this.surgeryId,
  });

  CollectionReference<Map<String, dynamic>> get _appointmentsCollection {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('pacients')
        .doc(pacientId)
        .collection('surgeries')
        .doc(surgeryId)
        .collection('appointments');
  }

  Future<List<Appointment>> getAppointments() async {
    try {
      final snapshot = await _appointmentsCollection.get();
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      await _appointmentsCollection.add(appointment.toMap());
    } catch (e) {
      throw Exception('Failed to add appointment: $e');
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _appointmentsCollection
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _appointmentsCollection.doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  static Future<List<Appointment>> getAllAppointments(String userId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final List<Appointment> allAppointments = [];

    final pacientsSnapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('pacients')
            .get();

    for (var pacientDoc in pacientsSnapshot.docs) {
      final surgeriesSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('pacients')
              .doc(pacientDoc.id)
              .collection('surgeries')
              .get();

      for (var surgeryDoc in surgeriesSnapshot.docs) {
        final appointmentsSnapshot =
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('pacients')
                .doc(pacientDoc.id)
                .collection('surgeries')
                .doc(surgeryDoc.id)
                .collection('appointments')
                .get();

        for (var appDoc in appointmentsSnapshot.docs) {
          final data = appDoc.data();
          final appointment = Appointment.fromMap(data, appDoc.id);
          allAppointments.add(appointment);
        }
      }
    }

    return allAppointments;
  }
}
