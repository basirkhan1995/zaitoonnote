import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'colors.dart';

 class Env{
   static final messengerKey = GlobalKey<ScaffoldMessengerState>();

   static void goto(route,context){
     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>route));
   }

   static showSnackBar2(String title, String message, snackType, context){
     final snackBar = SnackBar(
       elevation: 0,
       behavior: SnackBarBehavior.floating,
       backgroundColor: Colors.transparent,
       content: AwesomeSnackbarContent(
         color: Colors.deepPurple,
         title: Locales.string(context, title),
         message: Locales.string(context, message),
         contentType: snackType,
       ),
     );
     ScaffoldMessenger.of(context)
       ..hideCurrentSnackBar()
       ..showSnackBar(snackBar);
   }


   static showSnackBar(String title,String? message,context){
     if(message == null) return;
     final materialBanner = MaterialBanner(
       elevation: 0,
       backgroundColor: Colors.transparent,
       forceActionsBelow: true,
       content: AwesomeSnackbarContent(
         title: Locales.string(context, title),
         message: Locales.string(context, message),
         inMaterialBanner: true,
         contentType: ContentType.success,
       ), actions: const [SizedBox.shrink()],
     );


     ScaffoldMessenger.of(context)
       ..hideCurrentMaterialBanner()
       ..showMaterialBanner(materialBanner);
   }

 }

