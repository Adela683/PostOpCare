import 'package:postopcare/data/models/appointment.dart';

class Surgery {
  final String id;
  final String nume;
  final DateTime dataEfectuarii;
  final String templateId;
  final List<Appointment> appointments;

  Surgery({
    required this.id,
    required this.nume,
    required this.dataEfectuarii,
    required this.templateId,
    this.appointments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nume': nume,
      'dataEfectuarii': dataEfectuarii.toIso8601String(),
      'templateId': templateId,
      // Nu stocăm appointments aici, ele sunt stocate separat în subcolecția appointments
    };
  }

  factory Surgery.fromMap(
    Map<String, dynamic> map, {
    List<Appointment>? appointments,
  }) {
    return Surgery(
      id: map['id'] ?? '',
      nume: map['nume'] ?? '',
      dataEfectuarii: DateTime.parse(
        map['dataEfectuarii'] ?? DateTime.now().toIso8601String(),
      ),
      templateId: map['templateId'] ?? '',
      appointments: appointments ?? [],
    );
  }
}
