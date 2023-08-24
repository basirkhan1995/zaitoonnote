import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProvider extends ChangeNotifier{

  bool _darkLight = false;
  bool _rememberMe = false;
  bool _showHidePersianDate = false;
  bool _enableDisableLogin = false;
  bool _isLogin = false;

  bool get showHidePersianDate => _showHidePersianDate;
  bool get darkLight => _darkLight;
  bool get rememberMe => _rememberMe;
  bool get enableDisableLogin => _enableDisableLogin;
  bool get isLogin => _isLogin;

  late SharedPreferences secureStorage;

  void loginTrueFalse(){
    _isLogin = ! _isLogin;
    notifyListeners();
  }

  //To enable authentication page
  void enableLoginPage(){
    _enableDisableLogin = !_enableDisableLogin;
    _rememberMe = false;
    notifyListeners();
  }

   void toggle(){
     _showHidePersianDate = !_showHidePersianDate;
     notifyListeners();
   }


   storeSharedPreferences()async{
    secureStorage = await SharedPreferences.getInstance();
    secureStorage.setBool("persianDate", _showHidePersianDate);
    secureStorage.setBool("enableLoginPage", _enableDisableLogin);
    secureStorage.setBool("rememberMe", _rememberMe);
    notifyListeners();
  }

  initialize()async{
     secureStorage = await SharedPreferences.getInstance();
     _showHidePersianDate = secureStorage.getBool("persianDate")??false;
     _enableDisableLogin = secureStorage.getBool("enableLoginPage")??false;
     _rememberMe = secureStorage.getBool("rememberMe")??false;
     notifyListeners();
   }


  //Method to change
   changeTheme()async{
    _darkLight = !_darkLight;
    secureStorage = await SharedPreferences.getInstance();
    secureStorage.setBool("status", _darkLight);
    notifyListeners();
  }

  void setRememberMe()async{
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

}