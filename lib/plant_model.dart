class Plant {
  final int? id;
  final String name;
  final String disease;

  Plant({
    this.id,
    required this.name,
    required this.disease
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'disease': disease
    };
  }
}