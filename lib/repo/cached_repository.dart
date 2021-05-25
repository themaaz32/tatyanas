import 'package:shared_preferences/shared_preferences.dart';

import '../globals/consts/consts.dart';

class CachedImagesRepository {
  SharedPreferences _sharedPreferences;


  Future<void> updateImagesDataInCache(String newData) async{
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setString(AppConstants.userImagesCachedKey, newData);
    print("$newData is saved on key $AppConstants.userImagesCachedKey");
  }


  Future<String> getImagesDataFromCache()async{
    _sharedPreferences = await SharedPreferences.getInstance();
    final String imagesJson =  _sharedPreferences.getString(AppConstants.userImagesCachedKey);
    print("$imagesJson is fetched from the key $AppConstants.userImagesCachedKey");
    return imagesJson;
  }

  Future<bool> isDataAvailable() async{
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences.getString(AppConstants.userImagesCachedKey) != null;
  }

  static final CachedImagesRepository _repository = CachedImagesRepository
      ._internal();

  factory CachedImagesRepository(){
    return _repository;
  }

  CachedImagesRepository._internal();
}
