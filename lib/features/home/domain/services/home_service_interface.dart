import 'package:lestar_user/common/enums/data_source_enum.dart';
import 'package:lestar_user/features/home/domain/models/banner_model.dart';
import 'package:lestar_user/features/home/domain/models/cashback_model.dart';

abstract class HomeServiceInterface {
  Future<BannerModel?> getBannerList({required DataSourceEnum source});
  Future<List<CashBackModel>?> getCashBackOfferList({DataSourceEnum? source});
  Future<CashBackModel?> getCashBackData(double amount);
}
