class UserRequest {
  final String  fieldTitle;
  final int fieldid;
  final String experienceYears;
  final String cvurl;
  final int requestStatus;
  final String statuscomment;
  final String cityName;
  final String educationLeveltitle;

  UserRequest({
    required this.fieldTitle,
    required this.fieldid,
    required this.experienceYears,
    required this.cvurl,
    required this.requestStatus,
    required this.statuscomment,
    required this.cityName,
    required this.educationLeveltitle,

  });

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      fieldTitle: json['field'] !=null ? json['field'] ['exprienceFieldTitle'] : '',
      fieldid: json['field'] !=null ? json['field'] ['id'] : 0,
      experienceYears: json['experienceYears'] ?? '',
      cvurl: json['cvurl'] ?? '',
      requestStatus: json['requestStatus'] ?? 0,
      statuscomment: json['statuscomment'] ?? '',
      educationLeveltitle:  json['educationLevel']!=null? json['educationLevel']['educationLevel1']:'',
      cityName: json['city']!=null? json['city']['cityName']:'',
    );
  }
}