class Order {
  final int orderId;
  final DateTime orderDate;
  final String status;
  final double totalAmount;
  final int paymentStatus;
  final List<OrderItem> orderItems;
  final User? user;
  Order({
    required this.orderId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderItems,
    this.user,
  });
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      orderDate: DateTime.parse(json['orderDate']),
      status: json['status'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'],
      orderItems: (json['orderItems'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
class OrderItem {
  final int orderItemId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Experience experience;
  bool isEvaluated;
   double evaluation;
  final List<ExperienceSession>?  experienceSession;
  OrderItem({
    required this.orderItemId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.experience,
    required this.experienceSession,
    required this.isEvaluated,
    required this.evaluation,
  });
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['orderItemId'],
      quantity: json['quantity'],
      isEvaluated: json['isEvaluated'],
      evaluation: json['evaluation'] == null ? 0 : (json['evaluation'] as num).toDouble(),
      //evaluation: json['evaluation'] == null ? 0 : 4,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      experience: Experience.fromJson(json['exprience']),
      experienceSession: json['experienceSession'] != null
          ? (json['experienceSession'] as List).map((e) => ExperienceSession.fromJson(e)).toList()
          : null,
    );
  }
}
class Experience {
  Experience({
    required this.exprienceId,
    required this.exprienceName,
    required this.description,
    required this.price,
    required this.deliveryLink,
    required this.isActive,
    required this.isApproved,
    required this.approvedDate,
    required this.noofSeats,
    required this.trainningTopics,
    required this.trainningRequirement,
    required this.filesFormate,
    required this.programmingLangauge,
    required this.technicalsourcesLink,
    required this.sessionPeriodinminutes,
    required this.dayes,
    required this.startDate,
    required this.startTime,
    required this.availablesHoures,
    required this.availableIntervales,
    required this.user,
    required this.category,
    required this.deliveryMethod,
    required this.field,
    required this.licienseType,
    required this.period,
    required this.trainningType,
    required this.trainninglevel,
    required this.exorienceSessions,
    required this.itemsPurchased,

  });
  final int? exprienceId;
  static const String exprienceIdKey = "exprienceId";
  final String? exprienceName;
  static const String exprienceNameKey = "exprienceName";
  final String? description;
  static const String descriptionKey = "description";
  final double? price;
  static const String priceKey = "price";
  final String? deliveryLink;
  static const String deliveryLinkKey = "deliveryLink";
  final bool? isActive;
  static const String isActiveKey = "isActive";

  final bool? isApproved;
  static const String isApprovedKey = "isApproved";
  final DateTime? approvedDate;
  static const String approvedDateKey = "approvedDate";
  final dynamic noofSeats;
  static const String noofSeatsKey = "noofSeats";
  final String? trainningTopics;
  static const String trainningTopicsKey = "trainningTopics";
  final String? trainningRequirement;
  static const String trainningRequirementKey = "trainningRequirement";
  final String? filesFormate;
  static const String filesFormateKey = "filesFormate";
  final String? programmingLangauge;
  static const String programmingLangaugeKey = "programmingLangauge";
  final String? technicalsourcesLink;
  static const String technicalsourcesLinkKey = "technicalsourcesLink";
  final int? sessionPeriodinminutes;
  static const String sessionPeriodinminutesKey = "sessionPeriodinminutes";
  final String? dayes;
  static const String dayesKey = "dayes";
  final DateTime? startDate;
  static const String startDateKey = "startDate";
  final String? startTime;
  static const String startTimeKey = "startTime";
  final int? availablesHoures;
  static const String availablesHouresKey = "availablesHoures";
  final int? itemsPurchased;
  static const String itemsPurchasedKey = "itemsPurchased";
  final String? availableIntervales;
  static const String availableIntervalesKey = "availableIntervales";
  final User? user;
  static const String userKey = "user";
  final Category? category;
  static const String categoryKey = "category";
  final DeliveryMethod? deliveryMethod;
  static const String deliveryMethodKey = "deliveryMethod";
  final Field? field;
  static const String fieldKey = "field";
  final LicienseType? licienseType;
  static const String licienseTypeKey = "licienseType";
  final Period? period;
  static const String periodKey = "period";
  final TrainningType? trainningType;
  static const String trainningTypeKey = "trainningType";
  final dynamic trainninglevel;
  static const String trainninglevelKey = "trainninglevel";
  final List<ExperienceSession> exorienceSessions;
  static const String exorienceSessionsKey = "exorienceSessions";
  factory Experience.fromJson(Map<String, dynamic> json){
    return Experience(
      exprienceId: json["exprienceId"],
      itemsPurchased:json['itemsPurchased'],
      exprienceName: json["exprienceName"],
      description: json["description"],
      price: json["price"],
      deliveryLink: json["deliveryLink"],
      isActive: json["isActive"],
      isApproved: json["isApproved"],
      approvedDate: DateTime.tryParse(json["approvedDate"] ?? ""),
      noofSeats: json["noofSeats"],
      trainningTopics: json["trainningTopics"],
      trainningRequirement: json["trainningRequirement"],
      filesFormate: json["filesFormate"],
      programmingLangauge: json["programmingLangauge"],
      technicalsourcesLink: json["technicalsourcesLink"],
      sessionPeriodinminutes: json["sessionPeriodinminutes"],
      dayes: json["dayes"],
      startDate: DateTime.tryParse(json["startDate"] ?? ""),
      startTime: json["startTime"],
      availablesHoures: json["availablesHoures"],
      availableIntervales: json["availableIntervales"],
      user:json["user"] == null ? null : User.fromJson(json["user"]),
      category: json["category"] == null ? null : Category.fromJson(json["category"]),
      deliveryMethod: json["deliveryMethod"] == null ? null : DeliveryMethod.fromJson(json["deliveryMethod"]),
      field: json["field"] == null ? null : Field.fromJson(json["field"]),
      licienseType: json["licienseType"] == null ? null : LicienseType.fromJson(json["licienseType"]),
      period: json["period"] == null ? null : Period.fromJson(json["period"]),
      trainningType: json["trainningType"] == null ? null : TrainningType.fromJson(json["trainningType"]),
      trainninglevel: json["trainninglevel"],
      exorienceSessions: json["exorienceSessions"] == null ? [] : List<ExperienceSession>.from(json["exorienceSessions"]!.map((x) => ExperienceSession.fromJson(x))),
    );
  }

}
class ExperienceSession {
  ExperienceSession({
    required this.sessionId,
    required this.exprienceDay,
    required this.exprienceDate,
    required this.fromTime,
    required this.toTime,
    required this.price,
  });
  final int? sessionId;
  static const String sessionIdKey = "sessionId";
  final String? exprienceDay;
  static const String exprienceDayKey = "exprienceDay";
  final DateTime? exprienceDate;
  static const String exprienceDateKey = "exprienceDate";
  final String? fromTime;
  static const String fromTimeKey = "fromTime";
  final String? toTime;
  static const String toTimeKey = "toTime";
  final double? price;
  static const String priceKey = "price";
  factory ExperienceSession.fromJson(Map<String, dynamic> json){
    return ExperienceSession(
      sessionId: json["sessionId"],
      exprienceDay: json["exprienceDay"],
      exprienceDate: DateTime.tryParse(json["exprienceDate"] ?? ""),
      fromTime: json["fromTime"],
      toTime: json["toTime"],
      price: json["price"],
    );
  }

}
class TrainningType {
  TrainningType({
    required this.id,
    required this.trainningType,
  });
  final int? id;
  static const String idKey = "id";
  final String? trainningType;
  static const String trainningTypeKey = "trainningType";
  factory TrainningType.fromJson(Map<String, dynamic> json){
    return TrainningType(
      id: json["id"],
      trainningType: json["trainningType"],
    );
  }

}
class LicienseType {
  LicienseType({
    required this.id,
    required this.liciensyTypeTitle,
  });

  final int? id;
  static const String idKey = "id";
  final String? liciensyTypeTitle;
  static const String liciensyTypeTitleKey = "liciensyTypeTitle";
  factory LicienseType.fromJson(Map<String, dynamic> json){
    return LicienseType(
      id: json["id"],
      liciensyTypeTitle: json["liciensyTypeTitle"],
    );
  }

}
class DeliveryMethod {
  DeliveryMethod({
    required this.id,
    required this.deliveryMethodTitle,
  });
  final int? id;
  static const String idKey = "id";
  final String? deliveryMethodTitle;
  static const String deliveryMethodTitleKey = "deliveryMethodTitle";
  factory DeliveryMethod.fromJson(Map<String, dynamic> json){
    return DeliveryMethod(
      id: json["id"],
      deliveryMethodTitle: json["deliveryMethodTitle"],
    );
  }

}
class Category {
  final int categoryId;
  final String categoryName;
  final String iconUrl;
  Category({required this.categoryId, required this.categoryName,required this.iconUrl});
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      iconUrl: json['iconUrl'],
    );
  }
}

class Field {
  final int id;
  final String exprienceFieldTitle;
  Field({required this.id, required this.exprienceFieldTitle});
  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      exprienceFieldTitle: json['exprienceFieldTitle'],
    );
  }
}
class Period {
  final int id;
  final String expriencePeriod1;
  Period({
    required this.id,
    required this.expriencePeriod1,
  });
  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      id: json['id'],
      expriencePeriod1: json['expriencePeriod1'],
    );
  }
}
class User {
  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.typeId,
    required this.isActive,
    required this.city,
    required this.type,
  });
  final int? userId;
  static const String userIdKey = "userId";
  final String? fullName;
  static const String fullNameKey = "fullName";
  final String? email;
  static const String emailKey = "email";
  final String? phone;
  static const String phoneKey = "phone";
  final int? typeId;
  static const String typeIdKey = "typeId";
  final bool? isActive;
  static const String isActiveKey = "isActive";
  final City? city;
  static const String cityKey = "city";
  final Type? type;
  static const String typeKey = "type";
  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json["userId"],
      fullName: json["fullName"],
      email: json["email"],
      phone: json["phone"],
      typeId: json["typeId"],
      isActive: json["isActive"],
      city: json["city"] == null ? null : City.fromJson(json["city"]),
      type: json["type"] == null ? null : Type.fromJson(json["type"]),
    );
  }

}
class City {
  City({
    required this.id,
    required this.cityName,
  });
  final int? id;
  static const String idKey = "id";
  final String? cityName;
  static const String cityNameKey = "cityName";
  factory City.fromJson(Map<String, dynamic> json){
    return City(
      id: json["id"],
      cityName: json["cityName"],
    );
  }
}
class Type {
  Type({
    required this.id,
    required this.typeName,
  });
  final int? id;
  static const String idKey = "id";
  final String? typeName;
  static const String typeNameKey = "typeName";
  factory Type.fromJson(Map<String, dynamic> json){
    return Type(
      id: json["id"],
      typeName: json["typeName"],
    );
  }
}