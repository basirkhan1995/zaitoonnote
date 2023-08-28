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
    int? count = await handler.totalSumByCategoryAndPersonByDateRange(2, widget.person?.pId??0,firstSelectedDate.toString(),endSelectedDate.toString());
    setState(() => totalPaid = count??0);
    return totalPaid;
  }
  //Total Received count
  Future<int> sumReceived()async{
    int? count = await handler.totalSumByCategoryAndPersonByDateRange(3,widget.person?.pId??0,firstSelectedDate.toString(),endSelectedDate.toString());
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
    double credit = double.parse(totalReceived.toString());
    double debit = double.parse(totalPaid.toString());
    String currentLocale = Locales.currentLocale(context).toString();
    double balance = debit - credit;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            leading: Icon(Icons.sort_rounded),
          ),

       //Reports header
       Container(
         padding: const EdgeInsets.symmetric(vertical: 0),
         height: MediaQuery.of(context).size.height *.18,
         margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 6),
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(8),
           color: Colors.white,
           boxShadow: [
             BoxShadow(
               color: Colors.grey.withOpacity(0.5),
               spreadRadius: 1,
               blurRadius: 1,
               offset: const Offset(0, 0), // changes position of shadow
             ),
           ],
         ),

         child: Center(
           child: SingleChildScrollView(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,

               children: [
                 ListTile(visualDensity: VisualDensity(vertical: -4),title:   LocaleText("credit",style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey)),dense: true,trailing: Text(Env.amountFormat(totalPaid.toString()),style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.grey),),),
                 ListTile(visualDensity: VisualDensity(vertical: -4),title:   LocaleText("debit",style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey)),dense: true,trailing: Text(Env.amountFormat(totalReceived.toString()),style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,color: Colors.grey),),),
                 ListTile(visualDensity: VisualDensity(vertical: -4),title:   LocaleText("balance",style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey)),dense: true, trailing: Text(Env.amountFormat(balance.toString()),style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),),
               ],
             ),
           ),
         ),
       ),

       const Column(
        children: [
     ],
      )
        ],
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

