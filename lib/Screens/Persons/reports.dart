import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Activities/transaction_details.dart';
import 'dart:io';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../../Provider/provider.dart';
import '../Json Models/trn_model.dart';

class PersonReports extends StatefulWidget {
  final PersonModel? data;
  const PersonReports({super.key, this.data});

  @override
  State<PersonReports> createState() => _PersonReportsState();
}

class _PersonReportsState extends State<PersonReports> {

  late Future<List<TransactionModel>> transactions;
  late DatabaseHelper handler;

  DateTime? selectedTimeLine;

  int paid = 0;
  int received = 0;

  int selectedCategoryId = 0;
  String selectedCategoryName = "";

  final db = DatabaseHelper();

  final searchCtrl = TextEditingController();
  String keyword = "";

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    transactions = handler.getTransactionsBySingleDate(widget.data?.pId??0,selectedTimeLine.toString());
    handler.initDB().whenComplete(() async {
      setState(() {
        transactions = getTransactionByPersonId();
      });
    });
    _onRefresh();

  }

  //All Person Transaction By Date Range
  Future<List<TransactionModel>> getTransactionByPersonId() async {
    return await handler.getTransactionsBySingleDate(widget.data?.pId??0,selectedTimeLine.toString());
  }


  //Method to refresh data on pulling the list
  //Refresh Data
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getTransactionByPersonId();
    });
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context, listen: false);
    String currentLocale = Locales.currentLocale(context).toString();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EasyDateTimeLine(
                timeLineProps: const EasyTimeLineProps(
                  vPadding: 8,
                ),
                activeColor: const Color(0xFF6f4ea9),
                initialDate: DateTime.now(),
                locale: currentLocale == "en"? "en_US" : "fa_IR",
                headerProps: EasyHeaderProps(
                  padding: const EdgeInsets.only(right: 19,left: 8),
                  monthStyle: TextStyle(fontFamily: currentLocale == "en"? "Ubuntu" : "Dubai",color: Colors.blueGrey,fontWeight: FontWeight.bold),
                  monthPickerType: MonthPickerType.switcher,
                  selectedDateStyle: TextStyle(fontFamily: currentLocale == "en"? "Ubuntu" : "Dubai",fontSize: largeSize,fontWeight: FontWeight.bold)

                ),
                onDateChange: (selectedDate) {
                  setState(() {
                    selectedTimeLine = selectedDate;
                    _onRefresh();
                  });
                },

                dayProps: EasyDayProps(
                  todayHighlightStyle: TodayHighlightStyle.withBackground,
                  activeDayStrStyle: TextStyle(fontFamily: currentLocale == "en"? "Ubuntu" : "Dubai",color: Colors.white),
                  todayHighlightColor: const Color(0xffE1ECC8),
                ),
              ),
            ],
          ),


          Expanded(
            child: Container(
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
                                        horizontalTitleGap: 5,
                                        onTap: ()=>Env.goto(TransactionDetails(data: items[index]), context),
                                        dense: true,
                                        leading: SizedBox(
                                            height: 40,width: 40,
                                            child: CircleAvatar(
                                                radius: 50,
                                                backgroundImage: items[index].pImage!.isNotEmpty? Image.file(File(items[index].pImage!),fit: BoxFit.cover).image:const AssetImage("assets/Photos/no_user.jpg"))),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                        title: Row(
                                          children: [
                                            Text(items[index].person,style:const TextStyle(fontSize: normalSize,fontWeight: FontWeight.bold),),
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
                                        subtitle: Text(provider.showHidePersianDate? Env.persianDateTimeFormat(DateTime.parse(items[index].createdAt.toString())):Env.gregorianDateTimeForm(items[index].createdAt.toString()),style: const TextStyle(fontSize: smallSize,color: Colors.grey),),
                                        trailing: Column(
                                          children: [

                                            const SizedBox(height: 6),
                                            Expanded(child: Text(Env.currencyFormat(items[index].amount, "en_US"),style: const TextStyle(fontSize: normalSize),)),
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
          ),
        ],
      ),
    );
  }

}

