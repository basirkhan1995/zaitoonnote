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

   static showSnackBar(String title, String message, snackType, context){
     final snackBar = SnackBar(
       elevation: 5,
       duration: const Duration(milliseconds: 1500),
       behavior: SnackBarBehavior.fixed,
       backgroundColor: Colors.white,
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

   static String currencyFormat(double amount,String localeCurrency){
     String output = NumberFormat.decimalPatternDigits(decimalDigits: 2,locale: localeCurrency).format(amount).replaceAll(RegExp(r"([.]*00)(?!.*\d)"),"");
     return output;
   }


   static String persianFormatWithWeekDay(Date date){
       final format = date.formatter;
       return '${format.wN} ${format.d} ${format.mN}';
   }

   static gregorianDateTimeForm(String date){
     final format = DateTime.parse(date);
     final gregorian = DateFormat('yyyy-MM-dd').format(format);
     return gregorian;
   }

   static persianDateTimeFormat(DateTime date) {
     Jalali persian = date.toJalali();
     final f = persian.formatter;
     return '${f.yyyy}-${f.mm}-${f.dd}';
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

