import 'package:lestar_user/common/enums/data_source_enum.dart';
import 'package:lestar_user/features/address/domain/models/address_model.dart';
import 'package:lestar_user/interface/repository_interface.dart';

abstract class AddressRepoInterface<T>
    implements RepositoryInterface<AddressModel> {
  @override
  Future<List<AddressModel>?> getList({
    int? offset,
    bool isLocal = false,
    DataSourceEnum? source,
  });
}
