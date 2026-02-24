class Cart {
  Cart({
    required this.cartId,
    required this.createdDate,
    required this.updatedDate,
    required this.totalPrice,
    required this.cartItems,
    required this.user,
  });

  final int? cartId;
  static const String cartIdKey = "cartId";

  final DateTime? createdDate;
  static const String createdDateKey = "createdDate";

  final DateTime? updatedDate;
  static const String updatedDateKey = "updatedDate";

  final double? totalPrice;
  static const String totalPriceKey = "totalPrice";
  final List<CartItem> cartItems;
  static const String cartItemsKey = "cartItems";
  final User? user;
  static const String userKey = "user";


  factory Cart.fromJson(Map<String, dynamic> json){
    return Cart(
      cartId: json["cartId"],
      createdDate: DateTime.tryParse(json["createdDate"] ?? ""),
      updatedDate: DateTime.tryParse(json["updatedDate"] ?? ""),
      totalPrice: json["totalPrice"],
      cartItems: json["cartItems"] == null ? [] : List<CartItem>.from(json["cartItems"]!.map((x) => CartItem.fromJson(x))),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

}

class CartItem {
  CartItem({
    required this.cartItemId,
    required this.quantity,
    required this.addedDate,
    required this.exprience,
    required this.experienceSession,
  });

  final int? cartItemId;
  static const String cartItemIdKey = "cartItemId";

  final int? quantity;
  static const String quantityKey = "quantity";

  final DateTime? addedDate;
  static const String addedDateKey = "addedDate";

  final Exprience? exprience;
  static const String exprienceKey = "exprience";

  final List<RienceSession> experienceSession;
  static const String experienceSessionKey = "experienceSession";


  factory CartItem.fromJson(Map<String, dynamic> json){
    return CartItem(
      cartItemId: json["cartItemId"],
      quantity: json["quantity"],
      addedDate: DateTime.tryParse(json["addedDate"] ?? ""),
      exprience: json["exprience"] == null ? null : Exprience.fromJson(json["exprience"]),
      experienceSession: json["experienceSession"] == null ? [] : List<RienceSession>.from(json["experienceSession"]!.map((x) => RienceSession.fromJson(x))),
    );
  }

}

class RienceSession {
  RienceSession({
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


  factory RienceSession.fromJson(Map<String, dynamic> json){
    return RienceSession(
      sessionId: json["sessionId"],
      exprienceDay: json["exprienceDay"],
      exprienceDate: DateTime.tryParse(json["exprienceDate"] ?? ""),
      fromTime: json["fromTime"],
      toTime: json["toTime"],
      price: json["price"],
    );
  }

}

class Exprience {
  Exprience({
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

  final List<RienceSession> exorienceSessions;
  static const String exorienceSessionsKey = "exorienceSessions";


  factory Exprience.fromJson(Map<String, dynamic> json){
    return Exprience(
      exprienceId: json["exprienceId"],
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
      exorienceSessions: json["exorienceSessions"] == null ? [] : List<RienceSession>.from(json["exorienceSessions"]!.map((x) => RienceSession.fromJson(x))),
    );
  }

}

class Category {
  Category({
    required this.categoryId,
    required this.categoryName,
    required this.iconUrl

  });
  final int? categoryId;
  static const String categoryIdKey = "categoryId";
  final String? categoryName;
  static const String categoryNameKey = "categoryName";
  final String iconUrl;
  static const String iconUrlNameKey = "iconUrl";
  factory Category.fromJson(Map<String, dynamic> json){
    return Category(
      categoryId: json["categoryId"],
      categoryName: json["categoryName"],
        iconUrl:json["iconUrl"],
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

class Field {
  Field({
    required this.id,
    required this.exprienceFieldTitle,
  });

  final int? id;
  static const String idKey = "id";

  final String? exprienceFieldTitle;
  static const String exprienceFieldTitleKey = "exprienceFieldTitle";


  factory Field.fromJson(Map<String, dynamic> json){
    return Field(
      id: json["id"],
      exprienceFieldTitle: json["exprienceFieldTitle"],
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

class Period {
  Period({
    required this.id,
    required this.expriencePeriod1,
    required this.periodByDay,
    required this.categoryId,
  });
  final int? id;
  static const String idKey = "id";
  final String? expriencePeriod1;
  static const String expriencePeriod1Key = "expriencePeriod1";
  final dynamic periodByDay;
  static const String periodByDayKey = "periodByDay";
  final int? categoryId;
  static const String categoryIdKey = "categoryId";
  factory Period.fromJson(Map<String, dynamic> json){
    return Period(
      id: json["id"],
      expriencePeriod1: json["expriencePeriod1"],
      periodByDay: json["periodByDay"],
      categoryId: json["categoryId"],
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
