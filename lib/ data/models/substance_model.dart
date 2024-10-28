// lib/data/models/substance_model.dart

class Substance {
  final String id;
  final String imageUrl;             // URL or path of the image uploaded by the user
  final String name;                 // Name of the substance
  final String description;          // Description of the substance
  final String foundLocation;        // Specific Fokotany where the substance was found
  final String region;               // Region where the substance was found
  final String validationStatus;     // Status (Pending, Validated, Rejected) after AI validation
  final DateTime dateFound;          // Date the substance was found
  final bool isVerified;             // True if verified by AI (Botsonic), false otherwise
  final DateTime? validationDate;    // Date of AI validation
  final String? validatorComment;    // Any additional comment after validation

  Substance({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.foundLocation,
    required this.region,
    required this.validationStatus,
    required this.dateFound,
    this.isVerified = false,
    this.validationDate,
    this.validatorComment,
  });

  // You can also include methods like `fromJson` and `toJson` for serialization
  factory Substance.fromJson(Map<String, dynamic> json) {
    return Substance(
      id: json['id'],
      imageUrl: json['imageUrl'],
      name: json['name'],
      description: json['description'],
      foundLocation: json['foundLocation'],
      region: json['region'],
      validationStatus: json['validationStatus'],
      dateFound: DateTime.parse(json['dateFound']),
      isVerified: json['isVerified'] ?? false,
      validationDate: json['validationDate'] != null
          ? DateTime.parse(json['validationDate'])
          : null,
      validatorComment: json['validatorComment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'description': description,
      'foundLocation': foundLocation,
      'region': region,
      'validationStatus': validationStatus,
      'dateFound': dateFound.toIso8601String(),
      'isVerified': isVerified,
      'validationDate': validationDate?.toIso8601String(),
      'validatorComment': validatorComment,
    };
  }
}
