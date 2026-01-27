import 'package:lestar_user/features/coupon/domain/models/coupon_model.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:lestar_user/features/coupon/domain/models/customer_coupon_model.dart';

abstract class CouponServiceInterface {
  List<JustTheController>? generateToolTipControllerList(
    List<CouponModel>? couponList,
  );
  Future<List<CouponModel>?> getRestaurantCouponList({
    required int restaurantId,
  });
  Future<CustomerCouponModel?> getCouponList({
    int? customerId,
    int? restaurantId,
    int? orderRestaurantId,
    double? orderAmount,
  });
  Future<Response> applyCoupon({
    required String couponCode,
    int? restaurantID,
    double? orderAmount,
  });
}
