// model/Session.dart
class Session {
  final int sessionId;
  final int expertId;
  final String exprienceDay;
  final String exprienceDate;
  final String fromTime;
  final String toTime;
  final double price;
  final String zoomURL;
  final String password;
  final String experiencename;
  Session({
    required this.sessionId,
    required this.expertId,
    required this.exprienceDay,
    required this.exprienceDate,
    required this.fromTime,
    required this.toTime,
    required this.price,
    required this.zoomURL,
    required this.password,
    required this.experiencename,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'] ?? 0,
      expertId:json['expertId'] ?? 0,
      exprienceDay: json['exprienceDay'] ?? '',
      exprienceDate: json['exprienceDate'] ?? '',
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      zoomURL: json['zoomURL'] ?? '',
      password: json['password'] ?? '',
      experiencename:json['experienceName'] ?? '',
    );
  }
}