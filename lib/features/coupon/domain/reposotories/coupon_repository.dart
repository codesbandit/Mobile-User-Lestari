import 'package:lestar_user/api/api_client.dart';
import 'package:lestar_user/features/coupon/domain/models/coupon_model.dart';
import 'package:lestar_user/features/coupon/domain/models/customer_coupon_model.dart';
import 'package:lestar_user/features/coupon/domain/reposotories/coupon_repository_interface.dart';
import 'package:lestar_user/util/app_constants.dart';
import 'package:get/get_connect/connect.dart';

class CouponRepository implements CouponRepositoryInterface {
  final ApiClient apiClient;
  CouponRepository({required this.apiClient});

  @override
  Future<Response> applyCoupon({
    required String couponCode,
    int? restaurantID,
    double? orderAmount,
  }) async {
    return await apiClient.getData(
      '${AppConstants.couponApplyUri}$couponCode&restaurant_id=$restaurantID&order_amount=$orderAmount',
      handleError: true,
      showToaster: true,
    );
  }

  @override
  Future<CustomerCouponModel?> getCouponList({
    int? customerId,
    int? restaurantId,
    int? orderRestaurantId,
    double? orderAmount,
  }) async {
    CustomerCouponModel? customerCouponModel;
    Response response;

    if (orderRestaurantId != null && orderAmount != null) {
      response = await apiClient.getData(
        '${AppConstants.couponUri}?${restaurantId != null ? 'restaurant_id' : 'customer_id'}=${restaurantId ?? customerId}&order_restaurant_id=$orderRestaurantId&order_amount=$orderAmount',
      );
    } else {
      response = await apiClient.getData(
        '${AppConstants.couponUri}?${restaurantId != null ? 'restaurant_id' : 'customer_id'}=${restaurantId ?? customerId}',
      );
    }

    if (response.statusCode == 200) {
      customerCouponModel = CustomerCouponModel.fromJson(response.body);
    }
    return customerCouponModel;
  }

  @override
  Future<List<CouponModel>?> getRestaurantCouponList(int restaurantId) async {
    List<CouponModel>? couponList;
    Response response = await apiClient.getData(
      '${AppConstants.restaurantWiseCouponUri}?restaurant_id=$restaurantId',
    );
    if (response.statusCode == 200) {
      couponList = [];
      response.body.forEach((category) {
        couponList!.add(CouponModel.fromJson(category));
      });
    }
    return couponList;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }
}
