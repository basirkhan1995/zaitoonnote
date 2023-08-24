import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';

import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';

class PersonReports extends StatefulWidget {
  final PersonModel? person;
  const PersonReports({super.key, this.person});

  @override
  State<PersonReports> createState() => _PersonReportsState();
}

class _PersonReportsState extends State<PersonReports> {

  late DatabaseHelper handler;
  int totalPaid = 0 ;
  int totalReceived = 0;
  final db = DatabaseHelper();


  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    handler.initDB().whenComplete(() async {
      setState(() {

      });
    });
    _onRefresh();
  }


  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
     sumPaid();
     sumReceived();
    });
  }


  //Total Paid
  Future<int> sumPaid()async{
    int? count = await handler.totalPaidToPerson(2,widget.person?.pId??0);
    setState(() => totalPaid = count??0);
    return totalPaid;
  }
  //Total Received count
  Future<int> sumReceived()async{
    int? count = await handler.totalPaidToPerson(3,widget.person?.pId??0);
    setState(() => totalReceived = count??0);
    return totalReceived;
  }

  String label = '';
  String selectedDate = Jalali.now().toJalaliDateTime();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            onTap: ()async{
              Jalali? picked = await showPersianDatePicker(
                  context: context,
                  initialDate: Jalali.now(),
                  firstDate: Jalali(1385, 8),
                  lastDate: Jalali(1450, 9),
                  initialEntryMode:
                  PDatePickerEntryMode.calendarOnly,
                  initialDatePickerMode: PDatePickerMode.year,
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData(
                        dialogTheme: const DialogTheme(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(0)),
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  });
              if (picked != null && picked != selectedDate) {
                setState(() {
                  label = picked.toJalaliDateTime();
                });
              }
            },
            title:Text(label,style: TextStyle(color: Colors.black54),),

          ),


      Row(
        children: [
          box("total_paid", Env.amountFormat(totalPaid.toString()), Icons.currency_rupee),
          box("total_received", Env.amountFormat(totalReceived.toString()), Icons.currency_rupee),
        ],
      )
        ],
      ),
    );
  }

  box(title,stats,IconData icon){
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: EdgeInsets.symmetric(vertical: 10),
        height: 100,
        //width: MediaQuery.of(context).size.width *.4,
        decoration: BoxDecoration(
          color: zPrimaryColor.withOpacity(.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon),
                  Text(stats,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  LocaleText(title)
                ],
              ),
            )),
      ),
    );
  }
}

