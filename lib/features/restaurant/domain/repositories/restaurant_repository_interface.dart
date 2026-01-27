import 'package:lestar_user/common/enums/data_source_enum.dart';
import 'package:lestar_user/common/models/product_model.dart';
import 'package:lestar_user/common/models/restaurant_model.dart';
import 'package:lestar_user/features/restaurant/domain/models/recommended_product_model.dart';
import 'package:lestar_user/interface/repository_interface.dart';

abstract class RestaurantRepositoryInterface extends RepositoryInterface {
  @override
  Future<Restaurant?> get(String? id, {String slug = '', String? languageCode});
  @override
  Future<RestaurantModel?> getList({
    int? offset,
    String? filterBy,
    int? topRated,
    int? discount,
    int? veg,
    int? nonVeg,
    bool fromMap = false,
    DataSourceEnum? source,
  });
  Future<List<Restaurant>?> getRestaurantList({
    String? type,
    bool isRecentlyViewed = false,
    bool isOrderAgain = false,
    bool isPopular = false,
    bool isLatest = false,
    DataSourceEnum? source,
  });
  Future<RecommendedProductModel?> getRestaurantRecommendedItemList(
    int? restaurantId,
  );
  Future<List<Product>?> getCartRestaurantSuggestedItemList(int? restaurantID);
  Future<ProductModel?> getRestaurantProductList(
    int? restaurantID,
    int offset,
    int? categoryID,
    String type,
  );
  Future<ProductModel?> getRestaurantSearchProductList(
    String searchText,
    String? storeID,
    int offset,
    String type,
  );
}
