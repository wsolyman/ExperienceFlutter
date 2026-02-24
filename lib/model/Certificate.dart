// model/Certificate.dart
class Certificate {
  final String experienceName;
  final String experienceCategory;
  final String experienceField;
  final String issueDate;
  final String certificateURL;

  Certificate({
    required this.experienceName,
    required this.experienceCategory,
    required this.experienceField,
    required this.issueDate,
    required this.certificateURL,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      experienceName: json['experiencename']?.toString() ?? '',
      experienceCategory: json['experienceCategory'] ?? '',
      experienceField: json['experiencefield'] ?? '',
      issueDate: json['issueDate'] ?? '',
      certificateURL: json['certificateURL'] ?? '',
    );
  }
}