import 'package:image_picker/image_picker.dart';
import 'package:lestar_user/common/models/response_model.dart';
import 'package:lestar_user/features/profile/domain/models/update_user_model.dart';
import 'package:lestar_user/features/profile/domain/models/userinfo_model.dart';
import 'package:lestar_user/interface/repository_interface.dart';

abstract class ProfileRepositoryInterface extends RepositoryInterface {
  Future<ResponseModel> updateProfile(
    UpdateUserModel userInfoModel,
    XFile? data,
    String token,
  );
  Future<ResponseModel> changePassword(UserInfoModel userInfoModel);
}
