import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final DateTime date;
  final String time; // timpul ca String, ex: "14:00"
  final String surgeryName; // Numele operației asociate (opțional)
  final String patientName; // Numele pacientului (opțional)

  Appointment({
    required this.id,
    required this.date,
    required this.time,
    this.surgeryName = '',
    this.patientName = '',
  });

  factory Appointment.fromMap(
    Map<String, dynamic> map,
    String id, {
    String surgeryName = '',
    String patientName = '',
  }) {
    return Appointment(
      id: id,
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] as String,
      surgeryName: surgeryName,
      patientName: patientName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'time': time,
      // Optional: nu salvăm surgeryName și patientName aici deoarece sunt metadate
    };
  }
}
