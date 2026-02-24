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
class DeliveryMethod {
  final int id;
  final String deliveryMethodTitle;

  DeliveryMethod({
    required this.id,
    required this.deliveryMethodTitle,
  });

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    return DeliveryMethod(
      id: json['id'],
      deliveryMethodTitle: json['deliveryMethodTitle'],
    );
  }
}
class EducationLevel {
  final int id;
  final String educationLevel1;

  EducationLevel({
    required this.id,
    required this.educationLevel1,
  });

  factory EducationLevel.fromJson(Map<String, dynamic> json) {
    return EducationLevel(
      id: json['id'],
      educationLevel1: json['educationLevel1'],
    );
  }
}
class LicenseType {
  final int id;
  final String liciensyTypeTitle;

  LicenseType({
    required this.id,
    required this.liciensyTypeTitle,
  });

  factory LicenseType.fromJson(Map<String, dynamic> json) {
    return LicenseType(
      id: json['id'],
      liciensyTypeTitle: json['liciensyTypeTitle'],
    );
  }
}
class TrainingLevel {
  final int id;
  final String trainingLevelTitle;

  TrainingLevel({
    required this.id,
    required this.trainingLevelTitle,
  });

  factory TrainingLevel.fromJson(Map<String, dynamic> json) {
    return TrainingLevel(
      id: json['id'],
      trainingLevelTitle: json['trainningLevelTitle'],
    );
  }
}
class TrainingType {
  final int id;
  final String trainingType;

  TrainingType({
    required this.id,
    required this.trainingType,
  });

  factory TrainingType.fromJson(Map<String, dynamic> json) {
    return TrainingType(
      id: json['id'],
      trainingType: json['trainningType'], // maps the JSON key
    );
  }
}
class ExperienceField {
  final int id;
  final String experienceFieldTitle;

  ExperienceField({
    required this.id,
    required this.experienceFieldTitle,
  });

  factory ExperienceField.fromJson(Map<String, dynamic> json) {
    return ExperienceField(
      id: json['id'],
      experienceFieldTitle: json['exprienceFieldTitle'], // maps the JSON key
    );
  }
}

class Category {
  final int categoryId;
  final String categoryName;

  Category({
    required this.categoryId,
    required this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
    );
  }
}
class Period {
  final int id;
  final String expriencePeriod1;
  final int categoryId;
  Period({
    required this.id,
    required this.expriencePeriod1,
    required this.categoryId,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      id: json['id'], // maps old JSON key
      expriencePeriod1: json['expriencePeriod1'], // maps old JSON key
      categoryId: json['categoryId'],
    );
  }
}
class sessionItem {
  final String text;
  final String value;
  sessionItem({required this.text, required this.value});
}
class weeklyHoursItem {
  final String text;
  final String value;
  weeklyHoursItem({required this.text, required this.value});
}
class dayesItem {
  final String text;
  final String value;
  dayesItem({required this.text, required this.value});
}


