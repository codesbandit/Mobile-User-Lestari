import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lestar_user/common/enums/data_source_enum.dart';
import 'package:lestar_user/data_source/cache_response.dart';
import 'package:lestar_user/helper/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalClient {

  static Future<String?> organize(DataSourceEnum source, String cacheId, String? responseBody, Map<String, String>? header) async {
    SharedPreferences sharedPreferences = Get.find();
    switch(source) {
      case DataSourceEnum.client:
        try{
          if(GetPlatform.isWeb) {
            await sharedPreferences.setString(cacheId, responseBody??'');
          } else {
            DbHelper.insertOrUpdate(
              id: cacheId,
              data: CacheResponseCompanion(
                endPoint: drift.Value(cacheId),
                header: drift.Value(header.toString()),
                response: drift.Value(responseBody??''),
              ),
            );
          }
        } catch(e) {
          if (kDebugMode) {
            print('=====error occure in repo add api data: $e');
          }
        }
      case DataSourceEnum.local:
        try {
          if(GetPlatform.isWeb) {
            String? cacheData = sharedPreferences.getString(cacheId);
            return cacheData;
          } else {
            final CacheResponseData? cacheResponseData = await database.getCacheResponseById(cacheId);
            return cacheResponseData?.response;
          }

        } catch (e) {
          if (kDebugMode) {
            print('=====error occur in get local data repo: $e');
          }
        }
    }
    return null;
  }
}