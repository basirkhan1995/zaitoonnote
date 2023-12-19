import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaitoonnote/Screens/Authentications/login.dart';

class MyProvider extends ChangeNotifier{

  bool _darkLight = false;
  bool _rememberMe = false;
  bool _showHidePersianDate = false;
  bool _enableDisableLogin = true;
  bool _isLogin = false;
  bool _isFingerOn = true;
  bool _onBoarding = true;

  bool get showHidePersianDate => _showHidePersianDate;
  bool get darkLight => _darkLight;
  bool get rememberMe => _rememberMe;
  bool get enableDisableLogin => _enableDisableLogin;
  bool get isLogin => _isLogin;
  bool get isFingerOn => _isFingerOn;
  bool get onBoarding => _onBoarding;

  late SharedPreferences secureStorage;


  //Language Switch
  void switchLanguage(context, languageCode) async {
    Locales.change(context, languageCode);
    notifyListeners();
  }

   setLoginTrue(){
    _isLogin = true;
    secureStorage.setBool("isLogin", _isLogin);
    notifyListeners();
  }

  fingerPrint(){
    _isFingerOn = !_isFingerOn;
    secureStorage.setBool("finger", _isFingerOn);
    notifyListeners();
  }

   setOnboardingOff(){
    _onBoarding = false;
    secureStorage.setBool("isOnboardingOnOff", _onBoarding);
    notifyListeners();
   }

   logout(context){
    _isLogin = false;
    secureStorage.setBool("isLogin", _isLogin);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const LoginPage()));
    notifyListeners();
  }

  //To enable authentication page
  void enableLoginPage()async{
    _enableDisableLogin = !_enableDisableLogin;
    _isLogin = false;
    secureStorage.setBool("enableLoginPage", _enableDisableLogin);
    secureStorage.setBool("isLogin", _isLogin);
    notifyListeners();
  }

   void toggle()async{
     _showHidePersianDate = !_showHidePersianDate;
     secureStorage.setBool("persianDate", _showHidePersianDate);
     notifyListeners();
   }

  initialize()async{
     secureStorage = await SharedPreferences.getInstance();
     _showHidePersianDate = secureStorage.getBool("persianDate")??false;
     _enableDisableLogin = secureStorage.getBool("enableLoginPage")??false;
     _isLogin = secureStorage.getBool("isLogin")??false;
     _onBoarding = secureStorage.getBool("isOnboardingOnOff")??true;
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