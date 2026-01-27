import 'package:get/get.dart';
import 'package:lestar_user/features/auth/controllers/auth_controller.dart';
import 'package:lestar_user/features/profile/controllers/profile_controller.dart';
import 'package:lestar_user/features/profile/domain/models/userinfo_model.dart';

class ReferAndEarnController extends GetxController implements GetxService {
  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  Future<void> getUserInfo() async {
    if (Get.find<AuthController>().isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      await Get.find<ProfileController>().getUserInfo();
    }
    _userInfoModel = Get.find<ProfileController>().userInfoModel;
    update();
  }
}
