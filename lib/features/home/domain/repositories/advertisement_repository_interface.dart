import 'package:lestar_user/common/enums/data_source_enum.dart';
import 'package:lestar_user/features/home/domain/models/advertisement_model.dart';
import 'package:lestar_user/interface/repository_interface.dart';

abstract class AdvertisementRepositoryInterface extends RepositoryInterface {
  @override
  Future<List<AdvertisementModel>?> getList({
    int? offset,
    DataSourceEnum? source,
  });
}
