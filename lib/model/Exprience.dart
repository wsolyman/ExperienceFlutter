class Category {
  final int categoryId;
  final String categoryName;
  final String iconUrl;
  Category({required this.categoryId, required this.categoryName,required this.iconUrl});
  factory Category.fromJson(Map<String, dynamic> json) => Category(
    categoryId: json['categoryId'],
    categoryName: json['categoryName'],
    iconUrl: json['iconUrl'],
  );
}
class ExperienceSession {
  final int sessionId;
  final String exprienceDay;
  final String exprienceDate;
  final String fromTime;
  final String toTime;
  final double price;

  ExperienceSession({
    required this.sessionId,
    required this.exprienceDay,
    required this.exprienceDate,
    required this.fromTime,
    required this.toTime,
    required this.price,
  });

  factory ExperienceSession.fromJson(Map<String, dynamic> json) {
    return ExperienceSession(
      sessionId: json['sessionId'],
      exprienceDay: json['exprienceDay'],
      exprienceDate: json['exprienceDate'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
class ExperienceField {
  final int id;
  final String exprienceFieldTitle;

  ExperienceField({required this.id, required this.exprienceFieldTitle});

  factory ExperienceField.fromJson(Map<String, dynamic> json) =>
      ExperienceField(id: json['id'], exprienceFieldTitle: json['exprienceFieldTitle']);
}
class LicenseType {
  final int id;
  final String liciensyTypeTitle;

  LicenseType({required this.id, required this.liciensyTypeTitle});
  factory LicenseType.fromJson(Map<String, dynamic> json) => LicenseType(
    id: json['id'],
    liciensyTypeTitle: json['liciensyTypeTitle'],
  );
}

class TrainingType {
  final int id;
  final String trainningType;
  TrainingType({required this.id, required this.trainningType});
  factory TrainingType.fromJson(Map<String, dynamic> json) => TrainingType(
    id: json['id'],
    trainningType: json['trainningType'],
  );
}
class TrainingLevel {
  final int id;
  final String trainingLevelTitle;

  TrainingLevel({required this.id, required this.trainingLevelTitle});
  factory TrainingLevel.fromJson(Map<String, dynamic> json) => TrainingLevel(
    id: json['id'],
    trainingLevelTitle: json['trainningLevelTitle'],
  );
}
class DeliveryMethod {
  final int id;
  final String deliveryMethodTitle;
  DeliveryMethod({required this.id, required this.deliveryMethodTitle});
  factory DeliveryMethod.fromJson(Map<String, dynamic> json) => DeliveryMethod(
    id: json['id'],
    deliveryMethodTitle: json['deliveryMethodTitle'],
  );
}
class Period {
  final int id;
  final String expriencePeriod1;
  final int? periodByDay;
  final int categoryId;
  Period({
    required this.id,
    required this.expriencePeriod1,
    this.periodByDay,
    required this.categoryId,
  });
  // Factory constructor for creating from JSON
  factory Period.fromJson(Map<String, dynamic> json)
  => Period(
      id: json['id'] as int,
      expriencePeriod1: json['expriencePeriod1'] as String,
      periodByDay: json['periodByDay'] as int?,
      categoryId: json['categoryId'] as int,
    );

}
class User {
  final int userId;
  final String fullName;
  final String email;
  final City city;
  final double? totalEvaluations;
  final int? itemsPurchased;

  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.city,
    required this.totalEvaluations,
    required this.itemsPurchased
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      city: City.fromJson(json['city']),
      totalEvaluations: json['totalEvaluations'] != null ? (json['totalEvaluations'] as num).toDouble() : null,
      itemsPurchased: json['itemsPurchased'] != null ? (json['itemsPurchased'] as num).toInt() : null,
    );
  }
}
class City {
  final int id;
  final String cityName;

  City({required this.id, required this.cityName});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      cityName: json['cityName'],
    );
  }
}


class Experience {
  final int exprienceId;
  final String exprienceName;
  final String description;
  final Category category;
  final ExperienceField field;
  final DeliveryMethod? deliveryMethod;
  final Period? period;
  final bool isActive;
  final bool isApproved;
  final String? startDate;
  final String? startTime;
  final int? sessionPeriodinminutes;
  final String? dayes;
  final String? deliveryLink;
   final List<ExperienceSession>? sessions;
  // Additional fields from JSON
  final int? noofSeats;
  final int? availablesHoures;
  final String? trainningTopics;
  final String? trainningRequirement;
  final String? filesFormate;
  final String? programmingLangauge;
  final String? technicalsourcesLink;
  final String? availableIntervales;
  final double? price;
  final LicenseType? licenseType;
  final TrainingType? trainingType;
  final TrainingLevel? trainingLevel;
  final User user;

  Experience({
    required this.exprienceId,
    required this.exprienceName,
    required this.description,
    required this.category,
    required this.field,
    required this.user,
    this.deliveryMethod,
    this.period,
    this.deliveryLink,
    required this.isActive,
    required this.isApproved,
    this.startDate,
    this.startTime,
    this.sessionPeriodinminutes,
    this.dayes,
    this.sessions,
    this.noofSeats,
    this.availablesHoures,
    this.trainningTopics,
    this.trainningRequirement,
    this.filesFormate,
    this.programmingLangauge,
    this.technicalsourcesLink,
    this.availableIntervales,
    this.licenseType,
    this.trainingType,
    this.trainingLevel,
    required this.price,
  });
  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    exprienceId: json['exprienceId'],
    price: json['price'] != null ? (json['price'] as num).toDouble() : null,
    exprienceName: json['exprienceName'],
    description: json['description'] ?? '',
    category: Category.fromJson(json['category']),
    field: ExperienceField.fromJson(json['field']),
    user: User.fromJson(json['user']),
    deliveryMethod: json['deliveryMethod'] != null ? DeliveryMethod.fromJson(json['deliveryMethod']) : null,
    period:json['period'] != null ? Period.fromJson(json['period']) : null,
    isActive: json['isActive'],
    availablesHoures:json['availablesHoures'],
    isApproved: json['isApproved'],
    startDate: json['startDate'],
    startTime: json['startTime'],
    sessionPeriodinminutes: json['sessionPeriodinminutes'],
    dayes: json['dayes'],
    sessions: json['exorienceSessions'] != null
        ? (json['exorienceSessions'] as List).map((e) => ExperienceSession.fromJson(e)).toList()
        : null,
    noofSeats: json['noofSeats'],
    trainningTopics: json['trainningTopics'],
    trainningRequirement: json['trainningRequirement'],
    filesFormate: json['filesFormate'],
    programmingLangauge: json['programmingLangauge'],
    technicalsourcesLink: json['technicalsourcesLink'],
      availableIntervales:json['availableIntervales'],
    licenseType: json['licienseType'] != null ? LicenseType.fromJson(json['licienseType']) : null,
    trainingType: json['trainningType'] != null ? TrainingType.fromJson(json['trainningType']) : null,
    trainingLevel: json['trainninglevel'] != null ? TrainingLevel.fromJson(json['trainninglevel']) : null,
  );
}
