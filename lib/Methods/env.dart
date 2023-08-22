import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

 class Env{
   static final messengerKey = GlobalKey<ScaffoldMessengerState>();

   static void goto(route,context){
     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>route));
   }

   static void showSnackBar2(String? message){
     if(message == null) return;
     final snackBar = SnackBar(
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(5),
         ),
         behavior: SnackBarBehavior.floating,
         backgroundColor: zPurpleColor,
         content: Text(message,style: const TextStyle(color: Colors.white),)
     );
     messengerKey.currentState!..removeCurrentSnackBar()..showSnackBar(snackBar);
   }


   static void showSnackBar(String title,String? message,context){
     if(message == null) return;
     final materialBanner = MaterialBanner(
       elevation: 0,
       backgroundColor: Colors.transparent,
       forceActionsBelow: true,
       content: AwesomeSnackbarContent(
         title: title,
         message: message,
         inMaterialBanner: true,
         contentType: ContentType.success,
       ), actions: const [SizedBox.shrink()],
     );


     ScaffoldMessenger.of(context)
       ..hideCurrentMaterialBanner()
       ..showMaterialBanner(materialBanner);
   }

 }

