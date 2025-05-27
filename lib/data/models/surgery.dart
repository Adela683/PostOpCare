import 'package:postopcare/data/models/appointment.dart';

class Surgery {
  final String id;
  final String nume;
  final DateTime dataEfectuarii;
  final String templateId;
  final List<Appointment> appointments;
  final List<String> photosUrls; // lista URL poze

  Surgery({
    required this.id,
    required this.nume,
    required this.dataEfectuarii,
    required this.templateId,
    this.appointments = const [],
    this.photosUrls = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nume': nume,
      'dataEfectuarii': dataEfectuarii.toIso8601String(),
      'templateId': templateId,
      // Nu stocăm appointments aici, ele sunt stocate separat în subcolecția appointments
      'photosUrls': photosUrls, // salvăm lista URL poze în Firestore
    };
  }

  factory Surgery.fromMap(
    Map<String, dynamic> map, {
    List<Appointment>? appointments,
    List<String>? photosUrls,
  }) {
    // Dacă photosUrls nu e trecut explicit, încearcă să-l extragă din map
    List<String> extractedPhotosUrls = [];
    if (photosUrls != null) {
      extractedPhotosUrls = photosUrls;
    } else if (map['photosUrls'] != null && map['photosUrls'] is List) {
      // Convertim elementele în String (în caz că Firestore întoarce dynamic)
      extractedPhotosUrls = List<String>.from(map['photosUrls']);
    }

    return Surgery(
      id: map['id'] ?? '',
      nume: map['nume'] ?? '',
      dataEfectuarii: DateTime.parse(
        map['dataEfectuarii'] ?? DateTime.now().toIso8601String(),
      ),
      templateId: map['templateId'] ?? '',
      appointments: appointments ?? [],
      photosUrls: extractedPhotosUrls,
    );
  }
}
