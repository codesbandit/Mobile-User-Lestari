import 'dart:convert';

import 'package:get/get.dart';
import 'package:lestar_user/api/api_client.dart';
import 'package:lestar_user/api/local_client.dart';
import 'package:lestar_user/common/enums/data_source_enum.dart';
import 'package:lestar_user/common/models/product_model.dart';
import 'package:lestar_user/common/models/response_model.dart';
import 'package:lestar_user/common/models/review_model.dart';
import 'package:lestar_user/features/product/domain/models/review_body_model.dart';
import 'package:lestar_user/features/review/domain/repositories/review_repository_interface.dart';
import 'package:lestar_user/util/app_constants.dart';

class ReviewRepository implements ReviewRepositoryInterface {
  final ApiClient apiClient;
  ReviewRepository({required this.apiClient});

  @override
  Future<ResponseModel> submitReview(
    ReviewBodyModel reviewBody,
    bool isProduct,
  ) async {
    if (isProduct) {
      return _submitReview(reviewBody);
    } else {
      return _submitDeliveryManReview(reviewBody);
    }
  }

  @override
  Future<List<Product>?> getList({
    int? offset,
    String? type,
    DataSourceEnum? source,
  }) async {
    List<Product>? reviewedProductList;
    String cacheId = AppConstants.reviewedProductUri;

    switch (source!) {
      case DataSourceEnum.client:
        Response response = await apiClient.getData(
          '${AppConstants.reviewedProductUri}?type=$type',
        );

        if (response.statusCode == 200) {
          reviewedProductList = [];
          reviewedProductList.addAll(
            ProductModel.fromJson(response.body).products!,
          );
          LocalClient.organize(
            DataSourceEnum.client,
            cacheId,
            jsonEncode(response.body),
            apiClient.getHeader(),
          );
        }

      case DataSourceEnum.local:
        String? cacheResponseData = await LocalClient.organize(
          DataSourceEnum.local,
          cacheId,
          null,
          null,
        );
        if (cacheResponseData != null) {
          reviewedProductList = [];
          reviewedProductList.addAll(
            ProductModel.fromJson(jsonDecode(cacheResponseData)).products!,
          );
        }
    }
    return reviewedProductList;
  }

  Future<ResponseModel> _submitReview(ReviewBodyModel reviewBody) async {
    Response response = await apiClient.postData(
      AppConstants.reviewUri,
      reviewBody.toJson(),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  Future<ResponseModel> _submitDeliveryManReview(
    ReviewBodyModel reviewBody,
  ) async {
    Response response = await apiClient.postData(
      AppConstants.deliveryManReviewUri,
      reviewBody.toJson(),
      handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      return ResponseModel(false, response.statusText);
    }
  }

  @override
  Future<List<ReviewModel>?> getRestaurantReviewList(
    String? restaurantID,
  ) async {
    List<ReviewModel>? restaurantReviewList;
    Response response = await apiClient.getData(
      '${AppConstants.restaurantReviewUri}?restaurant_id=$restaurantID',
    );
    if (response.statusCode == 200) {
      restaurantReviewList = [];
      response.body.forEach(
        (review) => restaurantReviewList!.add(ReviewModel.fromJson(review)),
      );
    }
    return restaurantReviewList;
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
}
