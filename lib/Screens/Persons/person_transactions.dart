import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Screens/Activities/transaction_details.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/colors.dart';
import '../../Methods/env.dart';
import '../Json Models/trn_model.dart';

class PersonActivities extends StatefulWidget {
  final PersonModel? data;
  const PersonActivities({super.key, this.data});

  @override
  State<PersonActivities> createState() => _PersonActivitiesState();
}

class _PersonActivitiesState extends State<PersonActivities> {
  late Future<List<TransactionModel>> transactions;
  late Future<List<TransactionModel>> transactionsByDate;
  late DatabaseHelper handler;

  DateTime? firstSelectedDate;
  DateTime? endSelectedDate;

  double totalDebit = 0;
  double totalCredit = 0;

  int selectedCategoryId = 0;
  String selectedCategoryName = "";

  final db = DatabaseHelper();

  final searchCtrl = TextEditingController();
  String keyword = "";

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();

    transactions = handler.getTransactionByPersonId(widget.data?.pId.toString() ?? "");
    transactionsByDate = handler.getTransactionByDateRange(
        widget.data?.pId.toString() ?? "",
        firstSelectedDate.toString(),
        endSelectedDate.toString());

    handler.initDB().whenComplete(() async {
      setState(() {
        transactions = getAllTransactionByDate();
        transactions = getAllTransaction();
      });
    });
    _onRefresh();
  }

  //All Person Transaction By Date Range
  Future<List<TransactionModel>> getAllTransactionByDate() async {
    return await handler.getTransactionByDateRange(
        widget.data?.pId.toString() ?? "",
        firstSelectedDate.toString(),
        endSelectedDate.toString());
  }

  //All Transactions By Person
  Future<List<TransactionModel>> getAllTransaction() async {
    return await handler
        .getTransactionByPersonId(widget.data?.pId.toString() ?? "");
  }


  ////////////////////////////////////////////////////////
  Future<double> allTimeCredits()async{
    double? total = (await db.totalAmountByCategoryAndPerson(3, widget.data?.pId ?? 0))[0]['total'];
    setState(() {
      totalCredit = total??0;
    });
    return totalCredit;
  }

  Future<double> allTimeDebits()async{
    double? total = (await db.totalAmountByCategoryAndPerson(2, widget.data?.pId ?? 0,))[0]['total'];
    setState(() {
      totalDebit = total??0;
    });
    return totalDebit;
  }

  Future<double> creditByDate()async{
    double? total = (
        await db.totalAmountByCategoryPersonDate( 3,
        widget.data?.pId ?? 0,
        firstSelectedDate.toString(),
        endSelectedDate.toString()))[0]['total'];
    setState(() {
      totalCredit = total??0;
    });

    return totalCredit;
  }

  Future<double> debitByDate()async{
    double? total = (await db.totalAmountByCategoryPersonDate(2,
        widget.data?.pId ?? 0,
        firstSelectedDate.toString(),
        endSelectedDate.toString()))[0]['total'];
    setState(() {
      totalDebit = total??0;
    });
    return totalDebit;
  }
///////////////////////////////////////////

  //Refresh Data
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getAllTransaction();
      allTimeCredits();
      allTimeDebits();
    });
  }

  Future<void> _onDateRefresh() async {
    setState(() {
      transactions = getAllTransactionByDate();
      creditByDate();
      debitByDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double debit = double.parse(totalDebit.toString());
    double credit = double.parse(totalCredit.toString());
    double balance = credit - debit;
    String currentLocale = Locales.currentLocale(context).toString();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: Container(
                  padding: EdgeInsets.zero,
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: zPrimaryColor,
                      //border: Border.all(color: zPrimaryColor),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(
                    Icons.edit_calendar_rounded,
                    color: Colors.white,
                    size: 20,
                  )),
              onTap: () {
                currentLocale == "en" ? showPicker() : showPersianPicker();
              },
              trailing: Text(
                currentLocale == "en"
                    ? DateFormat('MMMMEEEEd').format(DateTime.now())
                    : Env.persianFormatWithWeekDay(Jalali.now()),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                    fontSize: mediumSize),
              ),
            ),
            //Reports header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
              height: MediaQuery.of(context).size.height * .18,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      ListTile(
                        visualDensity: const VisualDensity(vertical: -4),
                        title: LocaleText("credit",
                            style: TextStyle(
                                fontFamily:
                                    currentLocale == "en" ? "Ubuntu" : "Dubai",
                                fontSize: width/26,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        dense: true,
                        trailing: Text(
                          Env.currencyFormat(credit, "en_US"),
                          style: TextStyle(
                              fontSize: width/22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ),
                      ListTile(
                        visualDensity: const VisualDensity(vertical: -4),
                        title: LocaleText("debit",
                            style: TextStyle(
                                fontFamily:
                                    currentLocale == "en" ? "Ubuntu" : "Dubai",
                                fontSize: width/26,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        dense: true,
                        trailing: Text(
                          Env.currencyFormat(debit, "en_US"),
                          style: TextStyle(
                              fontSize: width/22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ),
                      ListTile(
                        visualDensity: const VisualDensity(vertical: -4),
                        title: LocaleText("balance",
                            style: TextStyle(
                                fontFamily:
                                    currentLocale == "en" ? "Ubuntu" : "Dubai",
                                fontSize: width/26,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        dense: true,
                        trailing: Text(
                            Env.currencyFormat(balance, "en_US"),
                            style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",
                                fontSize: width/22, fontWeight: FontWeight.bold, color: balance.toInt()<0?Colors.red.shade900:Colors.green)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 0),
                height: MediaQuery.of(context).size.height * .18,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                  builder: (BuildContext context,
                      AsyncSnapshot<List<TransactionModel>> snapshot) {
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
                            Image.asset("assets/Photos/empty.png", width: 250),
                          ]));
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      //a final variable (item) to hold the snapshot data
                      final items = snapshot.data ?? <TransactionModel>[];
                      return Scrollbar(
                        //The refresh indicator
                        child: RefreshIndicator(
                          onRefresh: endSelectedDate == null ? _onRefresh : _onDateRefresh,
                          child: SizedBox(
                            child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0, vertical: 4),
                                        child: ListTile(
                                          horizontalTitleGap: 3,
                                          dense: true,
                                          leading: SizedBox(
                                              height: 60,
                                              width: 60,
                                              child: CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage: items[index]
                                                          .pImage!
                                                          .isNotEmpty
                                                      ? Image.file(
                                                              File(items[index].pImage!),
                                                              fit: BoxFit.cover).image : const AssetImage("assets/Photos/no_user.jpg"))),
                                          contentPadding: const EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 6),
                                          title: Row(
                                            children: [
                                              Text(
                                                items[index].person,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(width: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                    color: items[index]
                                                                .trnCategory ==
                                                            "received"
                                                        ? Colors.lightGreen
                                                        : Colors.red.shade700,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                child: Icon(
                                                  items[index].trnCategory ==
                                                          "received"
                                                      ? UniconsLine
                                                          .arrow_down_left
                                                      : UniconsLine
                                                          .arrow_up_right,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            currentLocale != "en"
                                                ? Env.persianDateTimeFormat(
                                                    DateTime.parse(items[index]
                                                        .createdAt
                                                        .toString()))
                                                : Env.gregorianDateTimeForm(
                                                    items[index]
                                                        .createdAt
                                                        .toString()),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          trailing: Column(
                                            children: [
                                              const SizedBox(height: 6),
                                              Expanded(
                                                  child: Text(
                                                Env.currencyFormat(
                                                    items[index].amount,
                                                    "en_US"),
                                                style: TextStyle(
                                                    fontSize: 15,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
                                              )),
                                            ],
                                          ),
                                          onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionDetails(data: items[index]))).then((value){
                                            if(value){
                                              _onRefresh();
                                            }
                                          });
                                          },
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(.3)),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .9,
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
      ),
    );
  }

  showPicker() async {
    final DateTimeRange? dateTimeRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(3000),
        initialDateRange: DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 1))));
    if (dateTimeRange != null) {
      setState(() {
        firstSelectedDate = dateTimeRange.start;
        endSelectedDate = dateTimeRange.end;
        transactions = transactionsByDate;
        _onDateRefresh();
      });
    }
    return dateTimeRange;
  }

  showPersianPicker() async {
    var picked = await showPersianDateRangePicker(
      context: context,
      initialEntryMode: PDatePickerEntryMode.calendar,
      initialDateRange: JalaliRange(
        start: Jalali.now(),
        end: Jalali.now(),
      ),
      firstDate: Jalali(1350, 8),
      lastDate: Jalali(1500, 9),
    );
    if (picked != null) {
      setState(() {
        firstSelectedDate = picked.start.toDateTime();
        endSelectedDate = picked.end.toDateTime();
        transactions = transactionsByDate;
        _onDateRefresh();
      });
    }
    return picked;
  }
}
