class Expert {
  final List<UserExpert> data;
  final int totalCount;
  Expert({required this.data, required this.totalCount});
  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      data: (json['data'] as List).map((i) => UserExpert.fromJson(i)).toList(),
      totalCount: json['totalCount'] ?? 0,
    );
  }
}
class UserExpert {
  final int userId;
  final String fullName;
  final String? profileUrl;
  final double? totalEvaluations;
  final int? itemsPurchased;
  final List<ExperienceRequest> experiences;
  UserExpert({
    required this.userId,
    required this.fullName,
    this.profileUrl,
    required this.experiences,
    required this.totalEvaluations,
    required this.itemsPurchased
  });
  factory UserExpert.fromJson(Map<String, dynamic> json) {
    return UserExpert(
      userId: json['userId'],
      fullName: json['fullName'],
      profileUrl: json['profileUrl'] != null ? json['profileUrl']  : null,
      totalEvaluations: json['totalEvaluations'] != null ? (json['totalEvaluations'] as num).toDouble() : null,
      itemsPurchased: json['itemsPurchased'] != null ? (json['itemsPurchased'] as num).toInt() : null,
      experiences: (json['exprienceRequests'] as List)
          .map((i) => ExperienceRequest.fromJson(i))
          .toList(),
    );
  }
}
class ExperienceRequest {
  final String fieldTitle;
  final String years;
  final String education;
  ExperienceRequest({
    required this.fieldTitle,
    required this.years,
    required this.education,
  });
  factory ExperienceRequest.fromJson(Map<String, dynamic> json) {
    return ExperienceRequest(
      fieldTitle: json['field'] !=null ? json['field'] ['exprienceFieldTitle'] : '',
      years: json['experienceYears'],
      education:  json['educationLevel']!=null? json['educationLevel']['educationLevel1']:'',
    );
  }
}