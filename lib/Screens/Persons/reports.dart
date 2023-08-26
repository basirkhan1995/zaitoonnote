import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
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

  DateTime firstSelectedDate = DateTime.now();
  DateTime? endSelectedDate = DateTime.now();

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


  //Total Paid
  Future<int> sumPaid()async{
    int? count = await handler.totalSumByCategoryAndPerson(2, widget.person?.pId??0,firstSelectedDate.toString(),endSelectedDate.toString());
    setState(() => totalPaid = count??0);
    return totalPaid;
  }
  //Total Received count
  Future<int> sumReceived()async{
    int? count = await handler.totalSumByCategoryAndPerson(3,widget.person?.pId??0,firstSelectedDate.toString(),endSelectedDate.toString());
    setState(() => totalReceived = count??0);
    return totalReceived;
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      sumPaid();
      sumReceived();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title:Row(
              children: [
                Container(
                    padding:const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                    decoration: BoxDecoration(color: zPrimaryColor,borderRadius: BorderRadius.circular(4)),
                    child: Text(Env.persianDateTimeFormat(DateTime.parse(firstSelectedDate.toString())),style: const TextStyle(color: Colors.white),)),
                const SizedBox(width: 10),
                Container(
                    padding:const EdgeInsets.symmetric(horizontal: 4,vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: zPrimaryColor
                    ),
                    child: Text(Env.persianDateTimeFormat(DateTime.parse(endSelectedDate.toString())),style: const TextStyle(color: Colors.white),)),

              ],
            ),
            trailing: IconButton(
              onPressed: (){
                setState(() {
                  showPicker();
                });
              },
              icon: const Icon(Icons.date_range),
            ),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
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

  showPicker()async{
    final DateTimeRange? dateTimeRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 1)))
    );
    if(dateTimeRange != null){
      setState(() {
        firstSelectedDate = dateTimeRange.start;
        endSelectedDate = dateTimeRange.end;
        _onRefresh();
      });
    }
    return dateTimeRange;
  }

}

