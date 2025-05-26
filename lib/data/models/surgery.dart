class Surgery {
  final String id;
  final String nume;
  final DateTime dataEfectuarii;

  Surgery({
    required this.id,
    required this.nume,
    required this.dataEfectuarii,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nume': nume,
      'dataEfectuarii': dataEfectuarii.toIso8601String(),
    };
  }

  factory Surgery.fromMap(Map<String, dynamic> map) {
    return Surgery(
      id: map['id'] ?? '',
      nume: map['nume'] ?? '',
      dataEfectuarii: DateTime.parse(map['dataEfectuarii'] ?? DateTime.now().toIso8601String()),
    );
  }
}
