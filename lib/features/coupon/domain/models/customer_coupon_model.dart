class CustomerCouponModel {
  List<Coupon>? available;
  List<Coupon>? unavailable;

  CustomerCouponModel({this.available, this.unavailable});

  CustomerCouponModel.fromJson(Map<String, dynamic> json) {
    if (json['available'] != null) {
      available = <Coupon>[];
      json['available'].forEach((v) {
        available!.add(Coupon.fromJson(v));
      });
    }
    if (json['unavailable'] != null) {
      unavailable = <Coupon>[];
      json['unavailable'].forEach((v) {
        unavailable!.add(Coupon.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (available != null) {
      data['available'] = available!.map((v) => v.toJson()).toList();
    }
    if (unavailable != null) {
      data['unavailable'] = unavailable!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Coupon {
  int? id;
  String? title;
  String? code;
  String? startDate;
  String? expireDate;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  String? couponType;
  int? limit;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? data;
  int? totalUses;
  String? createdBy;
  String? customerId;
  String? slug;
  int? restaurantId;
  Restaurant? restaurant;
  List<Translations>? translations;

  Coupon({
    this.id,
    this.title,
    this.code,
    this.startDate,
    this.expireDate,
    this.minPurchase,
    this.maxDiscount,
    this.discount,
    this.discountType,
    this.couponType,
    this.limit,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.data,
    this.totalUses,
    this.createdBy,
    this.customerId,
    this.slug,
    this.restaurantId,
    this.restaurant,
    this.translations,
  });

  Coupon.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    startDate = json['start_date'];
    expireDate = json['expire_date'];
    minPurchase = json['min_purchase'] != null ? double.parse(json['min_purchase'].toString()) : 0;
    maxDiscount = json['max_discount'] != null ? double.parse(json['max_discount'].toString()) : 0;
    discount = json['discount'] != null ? double.parse(json['discount'].toString()) : 0;
    discountType = json['discount_type'];
    couponType = json['coupon_type'];
    limit = json['limit'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    data = json['data'];
    totalUses = json['total_uses'];
    createdBy = json['created_by'];
    customerId = json['customer_id'];
    slug = json['slug'];
    restaurantId = json['restaurant_id'];
    restaurant = json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['code'] = code;
    data['start_date'] = startDate;
    data['expire_date'] = expireDate;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['coupon_type'] = couponType;
    data['limit'] = limit;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['data'] = this.data;
    data['total_uses'] = totalUses;
    data['created_by'] = createdBy;
    data['customer_id'] = customerId;
    data['slug'] = slug;
    data['restaurant_id'] = restaurantId;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Restaurant {
  int? id;
  String? name;
  bool? gstStatus;
  String? gstCode;
  bool? freeDeliveryDistanceStatus;
  String? freeDeliveryDistanceValue;
  String? logoFullUrl;
  String? coverPhotoFullUrl;
  String? metaImageFullUrl;
  RestaurantConfig? restaurantConfig;
  List<Translations>? translations;
  List<Storage>? storage;

  Restaurant({
    this.id,
    this.name,
    this.gstStatus,
    this.gstCode,
    this.freeDeliveryDistanceStatus,
    this.freeDeliveryDistanceValue,
    this.logoFullUrl,
    this.coverPhotoFullUrl,
    this.metaImageFullUrl,
    this.restaurantConfig,
    this.translations,
    this.storage,
  });

  Restaurant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    gstStatus = json['gst_status'];
    gstCode = json['gst_code'];
    freeDeliveryDistanceStatus = json['free_delivery_distance_status'];
    freeDeliveryDistanceValue = json['free_delivery_distance_value'];
    logoFullUrl = json['logo_full_url'];
    coverPhotoFullUrl = json['cover_photo_full_url'];
    metaImageFullUrl = json['meta_image_full_url'];
    restaurantConfig = json['restaurant_config'] != null ? RestaurantConfig.fromJson(json['restaurant_config']) : null;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
    }
    if (json['storage'] != null) {
      storage = <Storage>[];
      json['storage'].forEach((v) {
        storage!.add(Storage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['gst_status'] = gstStatus;
    data['gst_code'] = gstCode;
    data['free_delivery_distance_status'] = freeDeliveryDistanceStatus;
    data['free_delivery_distance_value'] = freeDeliveryDistanceValue;
    data['logo_full_url'] = logoFullUrl;
    data['cover_photo_full_url'] = coverPhotoFullUrl;
    data['meta_image_full_url'] = metaImageFullUrl;
    if (restaurantConfig != null) {
      data['restaurant_config'] = restaurantConfig!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (storage != null) {
      data['storage'] = storage!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RestaurantConfig {
  int? id;
  int? restaurantId;
  bool? instantOrder;
  bool? customerDateOrderSratus;
  int? customerOrderDate;
  String? createdAt;
  String? updatedAt;
  int? halalTagStatus;
  bool? extraPackagingStatus;
  bool? isExtraPackagingActive;
  int? extraPackagingAmount;
  int? dineIn;
  int? scheduleAdvanceDineInBookingDuration;
  String? scheduleAdvanceDineInBookingDurationTimeFormat;

  RestaurantConfig({
    this.id,
    this.restaurantId,
    this.instantOrder,
    this.customerDateOrderSratus,
    this.customerOrderDate,
    this.createdAt,
    this.updatedAt,
    this.halalTagStatus,
    this.extraPackagingStatus,
    this.isExtraPackagingActive,
    this.extraPackagingAmount,
    this.dineIn,
    this.scheduleAdvanceDineInBookingDuration,
    this.scheduleAdvanceDineInBookingDurationTimeFormat,
  });

  RestaurantConfig.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantId = json['restaurant_id'];
    instantOrder = json['instant_order'];
    customerDateOrderSratus = json['customer_date_order_sratus'];
    customerOrderDate = json['customer_order_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    halalTagStatus = json['halal_tag_status'];
    extraPackagingStatus = json['extra_packaging_status'];
    isExtraPackagingActive = json['is_extra_packaging_active'];
    extraPackagingAmount = json['extra_packaging_amount'];
    dineIn = json['dine_in'];
    scheduleAdvanceDineInBookingDuration = json['schedule_advance_dine_in_booking_duration'];
    scheduleAdvanceDineInBookingDurationTimeFormat = json['schedule_advance_dine_in_booking_duration_time_format'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restaurant_id'] = restaurantId;
    data['instant_order'] = instantOrder;
    data['customer_date_order_sratus'] = customerDateOrderSratus;
    data['customer_order_date'] = customerOrderDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['halal_tag_status'] = halalTagStatus;
    data['extra_packaging_status'] = extraPackagingStatus;
    data['is_extra_packaging_active'] = isExtraPackagingActive;
    data['extra_packaging_amount'] = extraPackagingAmount;
    data['dine_in'] = dineIn;
    data['schedule_advance_dine_in_booking_duration'] = scheduleAdvanceDineInBookingDuration;
    data['schedule_advance_dine_in_booking_duration_time_format'] = scheduleAdvanceDineInBookingDurationTimeFormat;
    return data;
  }
}

class Translations {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translations({
    this.id,
    this.translationableType,
    this.translationableId,
    this.locale,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Translations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Storage {
  int? id;
  String? dataType;
  String? dataId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Storage({
    this.id,
    this.dataType,
    this.dataId,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Storage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dataType = json['data_type'];
    dataId = json['data_id'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['data_type'] = dataType;
    data['data_id'] = dataId;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


