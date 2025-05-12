import 'package:cloud_firestore/cloud_firestore.dart';

class SurgeryTemplate {
  final String id;
  final String name;
  final List<int> intervals; // Intervalele vor fi în săptămâni

  // Constructor
  SurgeryTemplate({
    required this.id,
    required this.name,
    required this.intervals,
  });

  // Convertirea unui SurgeryTemplate într-un Map pentru Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'intervals': intervals};
  }

  // Crearea unui SurgeryTemplate dintr-un DocumentSnapshot din Firestore
  factory SurgeryTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SurgeryTemplate(
      id: doc.id, // ID-ul documentului
      name: data['name'] ?? '',
      intervals: List<int>.from(
        data['intervals'] ?? [],
      ), // Intervalele ca listă de întregi (săptămâni)
    );
  }

  // Funcție pentru a adăuga un interval (săptămână)
  void addInterval(int week) {
    if (!intervals.contains(week)) {
      intervals.add(week);
      intervals.sort(); // Menține lista ordonată
    }
  }

  // Funcție pentru a elimina un interval (săptămână)
  void removeInterval(int week) {
    intervals.remove(week);
  }

  // Reprezentarea în format String a obiectului pentru debugging
  @override
  String toString() {
    return 'SurgeryTemplate(id: $id, name: $name, intervals: $intervals)';
  }
}
