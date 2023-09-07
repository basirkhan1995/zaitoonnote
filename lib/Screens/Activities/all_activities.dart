import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Activities/transaction_details.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../Json Models/trn_model.dart';
import 'create_transaction.dart';

class AllActivities extends StatefulWidget {
  const AllActivities({super.key});

  @override
  State<AllActivities> createState() => _AllActivitiesState();
}

class _AllActivitiesState extends State<AllActivities> {
  final db = DatabaseHelper();
  final searchCtrl = TextEditingController();
  String keyword = "";
  String activityTypeCategory = "activity";

  late DatabaseHelper handler;
  late Future<List<TransactionModel>> transactions;
  late Future<List<CategoryModel>> category;
  late Future<List<TransactionModel>> transactionsByDate;

  DateTime? firstSelectedDate;
  DateTime? endSelectedDate;
  DateTime? date;
  var today = DateTime.now().toIso8601String();

  bool isSearchOn = false;
  bool isFilterOn = false;
  //Method to get category from database
  Future<List<CategoryModel>> getCategories() async {
    return await handler.getCategories(activityTypeCategory);
  }

  int currentFilterIndex = 0;

  int selectedCategoryId = 0;
  String selectedCategoryName = "";

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();

    transactions = handler.getAllTransactions();
    transactionsByDate = handler.getTransactionDateRange(
        firstSelectedDate.toString(), endSelectedDate.toString());

    handler.initDB().whenComplete(() async {
      setState(() {
        transactions = getAllTransactionByDate();
        transactions = getAllTransaction();
        category = getCategories();
      });
    });
    _onRefresh();
   // _onDateRefresh();
  }

  //All Person Transaction By Date Range
  Future<List<TransactionModel>> getAllTransactionByDate() async {
    return await handler.getTransactionDateRange(
        firstSelectedDate.toString(), endSelectedDate.toString());
  }

  //All Transactions By Person
  Future<List<TransactionModel>> getAllTransaction() async {
    return await handler.getTodayTransactions(today);
  }



  //Refresh Data
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getAllTransaction();
      category = getCategories();
    });
  }

  //Refresh Data
  Future<void> _onDateRefresh() async {
    setState(() {
      //transactions = getAllTransaction();
      transactions = getAllTransactionByDate();
    });
  }

  late String refresh ;
  @override
  Widget build(BuildContext context) {
    String currentLocale = Locales.currentLocale(context).toString();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
        Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateTransaction())).then((value) {
                    if(value){
                      _onRefresh();
                    }
        });

        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 5),
              //Filter buttons
              isFilterOn? SizedBox(
                height: 50,
                child: FutureBuilder<List<CategoryModel>>(
                    future: category,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<CategoryModel>> snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox();
                        //If snapshot has error
                      } else if (snapshot.hasData &&
                          snapshot.data!.isEmpty) {
                        return const SizedBox();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        //a final variable (item) to hold the snapshot data
                        final items = snapshot.data ?? <CategoryModel>[];
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 0),
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  currentFilterIndex = index;
                                  transactions = db.filterTransactions(
                                      items[index].cName ?? "");
                                });
                              },
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: currentFilterIndex == index
                                        ? Colors.deepPurple.withOpacity(.5)
                                        : Colors.deepPurple.withOpacity(.1),
                                  ),
                                  child: Center(
                                    child: LocaleText(
                                      items[index].cName ?? "",
                                      style: TextStyle(
                                          color: currentFilterIndex == index
                                              ? Colors.white
                                              : Colors.deepPurple,
                                          fontSize: 14,
                                          fontWeight:
                                          currentFilterIndex == index
                                              ? FontWeight.bold
                                              : FontWeight.w400),
                                    ),
                                  )),
                            );
                          },
                        );
                      }
                    }),
              ):const SizedBox(),
              isSearchOn ? Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: TextFormField(
                        controller: searchCtrl,
                        onChanged: (value) {
                          setState(() {
                            keyword = searchCtrl.text;
                            transactions = db.transactionSearch(keyword);
                          });
                        },
                        decoration: InputDecoration(
                            hintText: Locales.string(context, "search"),
                            icon: const Icon(Icons.search),
                            border: InputBorder.none),
                      ),
                    ):const SizedBox(),

              //Header title
              ListTile(
                horizontalTitleGap: 6,
                leading: Container(
                    padding: EdgeInsets.zero,
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                        color: zPrimaryColor,
                        //border: Border.all(color: zPrimaryColor),
                        borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      splashRadius: 8,
                      onPressed: () => currentLocale == "en"
                          ? showGregorianPicker()
                          : showPersianPicker(),
                      icon: const Icon(Icons.edit_calendar_rounded,
                          color: Colors.white, size: 18),
                    )),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                title: LocaleText(endSelectedDate == null? "today_transaction" :"Filtered transactions",style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontWeight: FontWeight.bold,fontSize: 20),),
                trailing: Wrap(
                  children: [

                    IconButton(
                      onPressed: () => setState(() {
                        isSearchOn = !isSearchOn;
                      }),
                      icon: const Icon(UniconsLine.search),
                    ),

                    IconButton(
                      onPressed: () => setState(() {
                        isFilterOn = !isFilterOn;
                      }),
                      icon: const Icon(UniconsLine.filter),
                    ),


                  ],
                ),
              ),
              //All Transactions
              Expanded(
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
                        ],
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
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0, vertical: 0),
                                        child: ListTile(
                                          onTap: ()async{
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionDetails(data: items[index]))).then((value) {
                                              _onRefresh();
                                            });
                                            },
                                          leading: SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage: items[index]
                                                          .pImage!
                                                          .isNotEmpty
                                                      ? Image.file(
                                                          File(items[index]
                                                              .pImage!),
                                                          fit: BoxFit.cover,
                                                        ).image
                                                      : const AssetImage(
                                                          "assets/Photos/no_user.jpg"))),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 12),
                                          title: Row(
                                            children: [
                                              Text(
                                                items[index].person,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        currentLocale == "en"
                                                            ? "Ubuntu"
                                                            : "Dubai"),
                                              ),
                                              const SizedBox(width: 8),
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
                                                        BorderRadius.circular(4)),
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
                                          subtitle: Text(currentLocale != "en"
                                              ? Env.persianDateTimeFormat(
                                                  DateTime.parse(items[index]
                                                      .createdAt
                                                      .toString()))
                                              : Env.gregorianDateTimeForm(
                                                  items[index]
                                                      .createdAt
                                                      .toString())),
                                          trailing: Text(
                                            Env.currencyFormat(
                                                items[index].amount, "en_US"),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          dense: true,
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(.3)),
                                        width: MediaQuery.of(context).size.width *
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
            ],
          ),
        ),
      ),
    );
  }

  showGregorianPicker() async {
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
