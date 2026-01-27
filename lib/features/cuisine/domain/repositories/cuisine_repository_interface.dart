import 'package:lestar_user/common/enums/data_source_enum.dart';
import 'package:lestar_user/features/cuisine/domain/models/cuisine_model.dart';
import 'package:lestar_user/features/cuisine/domain/models/cuisine_restaurants_model.dart';
import 'package:lestar_user/interface/repository_interface.dart';

abstract class CuisineRepositoryInterface extends RepositoryInterface {
  @override
  Future<CuisineModel?> getList({int? offset, DataSourceEnum? source});
  Future<CuisineRestaurantModel?> getRestaurantList(int offset, int cuisineId);
}
