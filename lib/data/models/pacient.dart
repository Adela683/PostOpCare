class Pacient {
  final String id;
  final String nume;
  final int varsta;
  final String sex;
  final String? telefon;

  Pacient({
    required this.id,
    required this.nume,
    required this.varsta,
    required this.sex,
    this.telefon,
  });

  factory Pacient.fromMap(Map<String, dynamic> map) {
    return Pacient(
      id: map['id'] ?? '',
      nume: map['nume'] ?? '',
      varsta: map['varsta'] ?? 0,
      sex: map['sex'] ?? '',
      telefon: map['telefon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nume': nume,
      'varsta': varsta,
      'sex': sex,
      'telefon': telefon,
    };
  }
}
