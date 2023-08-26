import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/colors.dart';
import '../../Methods/env.dart';
import '../../Provider/provider.dart';
import '../Json Models/trn_model.dart';


class PersonActivities extends StatefulWidget {
  final PersonModel? data;
  const PersonActivities({super.key,this.data});

  @override
  State<PersonActivities> createState() => _PersonActivitiesState();
}

class _PersonActivitiesState extends State<PersonActivities> {
  final searchCtrl = TextEditingController();
  String keyword = "";

  int selectedCategoryId = 0;
  String selectedCategoryName = "";

  DateTime firstSelectedDate = DateTime.now();
  DateTime endSelectedDate = DateTime.now();
  late DatabaseHelper handler;
  late Future<List<TransactionModel>> transactions;
  final db = DatabaseHelper();
  var formatter = NumberFormat('#,##,000');
  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    transactions = handler.getByTransactionPerson(widget.data?.pId.toString()??"",firstSelectedDate.toString(),endSelectedDate.toString());
    handler.initDB().whenComplete(() async {
      setState(() {
        transactions = getAllTransactionByPersonId();
      });
    });
    _onRefresh();
  }

  //Method to get data from database
  Future<List<TransactionModel>> getAllTransactionByPersonId() async {
    return await handler.getByTransactionPerson(widget.data?.pId.toString()??"",firstSelectedDate.toString(),endSelectedDate.toString());
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getAllTransactionByPersonId();
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context, listen: false);
    return Scaffold(
      body:  SafeArea(
        child: Column(
          children: [

            //filter
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
                      decoration: BoxDecoration(color: zPrimaryColor,borderRadius: BorderRadius.circular(4)),
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

            //Filter
            Expanded(
              child: FutureBuilder<List<TransactionModel>>(
                future: transactions,
                builder: (BuildContext context, AsyncSnapshot<List<TransactionModel>> snapshot) {
                  //in case whether data is pending
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      //To show a circular progress indicator
                      child: CircularProgressIndicator(),
                    );
                    //If snapshot has error
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/Photos/empty.png",width: 250),
                          ]
                        ));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    //a final variable (item) to hold the snapshot data
                    final items = snapshot.data ?? <TransactionModel>[];
                    return Scrollbar(
                      //The refresh indicator
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: SizedBox(
                          child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context,index){
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 4),
                                      child: ListTile(
                                        dense: true,

                                        leading: SizedBox(
                                            height: 60,width: 60,
                                            child: CircleAvatar(
                                                radius: 50,
                                                backgroundImage: items[index].pImage!.isNotEmpty? Image.file(File(items[index].pImage!),fit: BoxFit.cover).image:const AssetImage("assets/Photos/no_user.jpg"))),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                                        title: Row(
                                          children: [
                                            Text(items[index].person,style:const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 3),
                                              decoration: BoxDecoration(
                                                  color: items[index].trnCategory == "received"? Colors.lightGreen:Colors.red.shade700,
                                                  borderRadius: BorderRadius.circular(4)
                                              ),
                                              child: Icon(
                                                items[index].trnCategory == "received"? UniconsLine.arrow_down_left:UniconsLine.arrow_up_right, color: Colors.white,size: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Text(provider.showHidePersianDate? Env.persianDateTimeFormat(DateTime.parse(items[index].createdAt.toString())):Env.gregorianDateTimeForm(items[index].createdAt.toString()),style: const TextStyle(),),
                                        trailing: Column(
                                          children: [

                                            const SizedBox(height: 6),
                                            Expanded(child: Text(Env.amountFormat(items[index].amount.toString()),style: const TextStyle(fontSize: 20),)),
                                          ],
                                        ),

                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(color: Colors.grey.withOpacity(.3)),
                                      width: MediaQuery.of(context).size.width *.9,
                                      height: 1,
                                      margin: EdgeInsets.zero,
                                    )
                                  ],
                                );
                              }),

                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
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


