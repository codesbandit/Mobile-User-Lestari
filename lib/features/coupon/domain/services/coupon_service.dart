import 'package:lestar_user/features/coupon/domain/models/coupon_model.dart';
import 'package:lestar_user/features/coupon/domain/models/customer_coupon_model.dart';
import 'package:lestar_user/features/coupon/domain/reposotories/coupon_repository_interface.dart';
import 'package:lestar_user/features/coupon/domain/services/coupon_service_interface.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class CouponService implements CouponServiceInterface {
  final CouponRepositoryInterface couponRepositoryInterface;
  CouponService({required this.couponRepositoryInterface});

  @override
  Future<CustomerCouponModel?> getCouponList({
    int? customerId,
    int? restaurantId,
    int? orderRestaurantId,
    double? orderAmount,
  }) async {
    return await couponRepositoryInterface.getCouponList(
      customerId: customerId,
      restaurantId: restaurantId,
      orderRestaurantId: orderRestaurantId,
      orderAmount: orderAmount,
    );
  }

  @override
  Future<List<CouponModel>?> getRestaurantCouponList({
    required int restaurantId,
  }) async {
    return await couponRepositoryInterface.getRestaurantCouponList(
      restaurantId,
    );
  }

  @override
  List<JustTheController>? generateToolTipControllerList(
    List<CouponModel>? couponList,
  ) {
    List<JustTheController>? toolTipController;
    if (couponList != null) {
      toolTipController = [];
      for (int i = 0; i < couponList.length; i++) {
        toolTipController.add(JustTheController());
      }
    }
    return toolTipController;
  }

  @override
  Future<Response> applyCoupon({
    required String couponCode,
    int? restaurantID,
    double? orderAmount,
  }) async {
    return await couponRepositoryInterface.applyCoupon(
      couponCode: couponCode,
      restaurantID: restaurantID,
      orderAmount: orderAmount,
    );
  }
}
