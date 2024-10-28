
class Permit {
  final int id;
  final String name;
  final String owner;
  final String substance;
  final String type;
  final String geom;

  Permit({required this.id, required this.name, required this.owner, required this.substance, required this.type, required this.geom});

  factory Permit.fromJson(Map<String, dynamic> json) {
    return Permit(
      id: json['id'],
      name: json['name'],
      owner: json['owner'],
      substance: json['substance'],
      type: json['type'],
      geom: json['geom'],
    );
  }

  toJson() {}
}
