import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

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

   static String amountFormat(value){
     String price = value;
     String priceInText = "";
     int counter = 0;
     for(int i = (price.length - 1);  i >= 0; i--){
       counter++;
       String str = price[i];
       if((counter % 3) != 0 && i !=0){
         priceInText = "$str$priceInText";
       }else if(i == 0 ){
         priceInText = "$str$priceInText";

       }else{
         priceInText = ",$str$priceInText";
       }
     }
     return priceInText.trim();
   }


   static String persianFormatWithWeekDay(Date date){
       final format = date.formatter;
       return '${format.wN} ${format.d} ${format.mN}';
   }


   static gregorianDateTimeForm(String date){
     final format = DateTime.parse(date);
     final gregorian = DateFormat('yyyy-MM-dd – kk:mm a').format(format);
     return gregorian;
   }

   static persianDateTimeFormat(DateTime date) {
     Jalali persian = date.toJalali();
     final f = persian.formatter;
     return '${f.yyyy}/${f.mm}/${f.dd}';
   }

   static persianDatePicker(var pickedDate,context)async{
      pickedDate = await showPersianDateRangePicker(
       context: context,
       initialEntryMode: PDatePickerEntryMode.input,
       initialDateRange: JalaliRange(
         start: Jalali(1400, 1, 2),
         end: Jalali(1400, 1, 10),
       ),
       firstDate: Jalali(1385, 8),
       lastDate: Jalali(1450, 9),
     );
     return pickedDate;
   }



 }

