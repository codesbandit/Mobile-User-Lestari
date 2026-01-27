import 'package:get/get_connect/http/src/response/response.dart';
import 'package:lestar_user/features/wallet/domain/models/fund_bonus_model.dart';
import 'package:lestar_user/features/wallet/domain/models/wallet_model.dart';
import 'package:lestar_user/interface/repository_interface.dart';

abstract class WalletRepositoryInterface extends RepositoryInterface {
  @override
  Future<WalletModel?> getList({int? offset, String sortingType});
  Future<Response> addFundToWallet(double amount, String paymentMethod);
  Future<List<FundBonusModel>?> getWalletBonusList();
  Future<void> setWalletAccessToken(String token);
  String getWalletAccessToken();
}
