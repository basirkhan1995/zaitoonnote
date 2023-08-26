import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../Datebase Helper/sqlite.dart';
import '../Methods/colors.dart';
import '../Methods/env.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late DatabaseHelper handler;
  int totalPaid = 0 ;
  int totalReceived = 0;
  int totalUser = 0;


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

//Total Received count
  Future<int> users()async{
    int? count = await handler.totalUsers();
    setState(() => totalUser = count??0);
    return totalUser;
  }

  //Total Received count
  Future<int> received()async{
    int? count = await handler.totalAmountToday(3);
    setState(() => totalReceived = count??0);
    return totalReceived;
  }
  //Total Received count
  Future<int> paid()async{
    int? count = await handler.totalAmountToday(2);
    setState(() => totalPaid = count??0);
    return totalPaid;
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      users();
      received();
      paid();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: LocaleText("today",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
              ),
              Row(
                children: [
                  box("accounts", totalUser.toString(),2,Colors.blueGrey.withOpacity(.3)),
                  box("total_paid", Env.amountFormat(totalReceived.toString()),3,zColor2),
                ],
              ),
              Row(
                children: [
                  box("total_received", Env.amountFormat(totalPaid.toString()),1,zBlue.withOpacity(.2)),

                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  box(title,stats,flex, Color backgroundColor){
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 10),
        height: 80,
        //width: MediaQuery.of(context).size.width *.4,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Text(stats,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  LocaleText(title)
                ],
              ),
            )),
      ),
    );
  }
}
