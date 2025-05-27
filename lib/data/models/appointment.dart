import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String id;
  final DateTime date;
  final String time; // storing time as String like "14:30"

  Appointment({required this.id, required this.date, required this.time});

  factory Appointment.fromMap(Map<String, dynamic> map, String id) {
    return Appointment(
      id: id,
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': date, 'time': time};
  }
}
