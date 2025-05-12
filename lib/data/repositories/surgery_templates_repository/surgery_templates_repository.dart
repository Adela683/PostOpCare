import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postopcare/data/models/surgery_templates.dart';
export 'package:postopcare/data/models/surgery_templates.dart';

class SurgeryTemplateRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String
  _userId; // ID-ul utilizatorului, pentru a asocia template-urile fiecărui utilizator

  SurgeryTemplateRepository({required String userId}) : _userId = userId;

  // Colecția de surgery templates din Firestore
  CollectionReference get _templatesCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('surgery_templates');
  }

  // Adăugarea unui nou template
  Future<void> addTemplate(SurgeryTemplate template) async {
    try {
      await _templatesCollection.add(template.toMap());
    } catch (e) {
      throw Exception('Failed to add template: $e');
    }
  }

  // Preluarea tuturor template-urilor
  Future<List<SurgeryTemplate>> getAllTemplates() async {
    try {
      QuerySnapshot snapshot = await _templatesCollection.get();
      return snapshot.docs.map((doc) {
        return SurgeryTemplate.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load templates: $e');
    }
  }

  // Actualizarea unui template existent
  Future<void> updateTemplate(SurgeryTemplate template) async {
    try {
      await _templatesCollection.doc(template.id).update(template.toMap());
    } catch (e) {
      throw Exception('Failed to update template: $e');
    }
  }

  // Ștergerea unui template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _templatesCollection.doc(templateId).delete();
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }
}
