import 'package:flutter/material.dart';
import 'colors.dart';

 class Env{
   static final messengerKey = GlobalKey<ScaffoldMessengerState>();

   static void goto(route,context){
     Navigator.of(context).push(MaterialPageRoute(builder: (context)=>route));
   }

   static showSnackBar(String? message){

     if(message == null) return;
     final snackBar = SnackBar(
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(5),
         ),
         behavior: SnackBarBehavior.floating,
         backgroundColor: zPurple,
         content: Text(message,style: const TextStyle(color: Colors.white),)
     );

     messengerKey.currentState!..removeCurrentSnackBar()..showSnackBar(snackBar);
   }

 }