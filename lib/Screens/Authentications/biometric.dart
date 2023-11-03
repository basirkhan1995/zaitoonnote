import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuth{
  static final _auth = LocalAuthentication();
  static Future<bool> canAuthenticate()async => await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  static Future<bool> authenticate()async{
    try{
      if(!await canAuthenticate())return false;
      return await _auth.authenticate(
          localizedReason: "Touch the finger print sensor to access zWallet",

          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
            sensitiveTransaction: true,
          )
      );

    }on PlatformException catch(e){
      print("error $e");
     return false;
    }
  }
}