import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProvider with ChangeNotifier{
  bool _darkLight = false;
  bool _rememberMe = false;

  bool get darkLight => _darkLight;
  bool get rememberMe => _rememberMe;

  late SharedPreferences secureStorage;

  //Method to change
  void changeTheme()async{
    _darkLight = !_darkLight;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("status", _darkLight);
    notifyListeners();
  }

  void setRememberMe()async{
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

}