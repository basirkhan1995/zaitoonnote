import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Screens/Activities/transaction_details.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import '../../../Datebase Helper/sqlite.dart';
import '../../../Methods/colors.dart';
import '../../../Methods/env.dart';
import '../../../Provider/provider.dart';
import '../../Json Models/trn_model.dart';



class GeneralTransactionReports extends StatefulWidget {
  final PersonModel? data;
  const GeneralTransactionReports({super.key,this.data});

  @override
  State<GeneralTransactionReports> createState() => _GeneralTransactionReportsState();
}

class _GeneralTransactionReportsState extends State<GeneralTransactionReports> {

  late Future<List<TransactionModel>> transactions;
  late Future<List<TransactionModel>> transactionsByDate;
  late DatabaseHelper handler;

  DateTime? firstSelectedDate;
  DateTime? endSelectedDate;

  double allTimePaid = 0;
  double allTimeReceived = 0;

  int selectedCategoryId = 0;
  String selectedCategoryName = "";

  final db = DatabaseHelper();

  final searchCtrl = TextEditingController();
  String keyword = "";

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();

    transactions = handler.getTransactionByPersonId(widget.data?.pId.toString()??"");
    transactionsByDate = handler.getTransactionByDateRange(widget.data?.pId.toString()??"",firstSelectedDate.toString(),endSelectedDate.toString());

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
    return await handler.getTransactionDateRange(firstSelectedDate.toString(),endSelectedDate.toString());
  }

  //All Transactions By Person
  Future<List<TransactionModel>> getAllTransaction() async {
    return await handler.getAllTransactions();
  }

  Future<double> creditsByDate()async{
    double? total = (await db.totalAmountByCategoryDate(3,firstSelectedDate.toString(),endSelectedDate.toString()))[0]['total'];
    setState(() {
      allTimeReceived = total??0;
    });
    return allTimeReceived;
  }

  Future<double> debitsByDate()async{
    double? total = (await db.totalAmountByCategoryDate(2,firstSelectedDate.toString(),endSelectedDate.toString()))[0]['total'];
    setState(() {
      allTimePaid = total??0;
    });
    return allTimePaid;
  }



  //////////////////////////////////
  Future<double> totalAllTimeCredit()async{
    double? total = (await db.totalAmountByCategory(3))[0]['total'];
    setState(() {
      allTimeReceived = total??0;
    });
    return allTimeReceived;
  }

  Future<double> totalAllTimeDebit()async{
    double? total = (await db.totalAmountByCategory(2))[0]['total'];
    setState(() {
      allTimePaid = total??0;
    });
    return allTimePaid;
  }

  //Refresh Data
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getAllTransaction();
      totalAllTimeCredit();
      totalAllTimeDebit();
    });
  }

  Future<void> _onDateRefresh() async {
    setState(() {
      transactions = getAllTransactionByDate();
      creditsByDate();
      debitsByDate();
    });
  }




  @override
  Widget build(BuildContext context) {



    double width = MediaQuery.of(context).size.width;
    final provider = Provider.of<MyProvider>(context, listen: false);
    String currentLocale = Locales.currentLocale(context).toString();

    double debit = double.parse(allTimePaid.toString());
    double credit = double.parse(allTimeReceived.toString());
    double balance = credit - debit;


    return Scaffold(
      body:  SafeArea(
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.only(right: 18,left: 10),
              leading: Container(
                  padding: EdgeInsets.zero,
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: zPrimaryColor,
                      //border: Border.all(color: zPrimaryColor),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.edit_calendar_rounded,color: Colors.white,)),
              onTap: (){
                currentLocale == "en"?showGregorianPicker():showPersianPicker();
              },
              title: Text( currentLocale == "en" ?DateFormat('MMMMEEEEd').format(DateTime.now()): Env.persianFormatWithWeekDay(Jalali.now()),style: TextStyle(fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: mediumSize),),
              trailing: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.deepPurple.withOpacity(.2)
                ),
                child: IconButton(
                  onPressed: ()=>Navigator.pop(context),
                  icon: const Icon(Icons.arrow_forward_ios,size:14),
                ),
              )
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
                      ListTile(visualDensity: const VisualDensity(vertical: -4),title:   LocaleText("credit",style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: width/26,fontWeight: FontWeight.bold,color: Colors.grey)),dense: true,trailing: Text(Env.currencyFormat(credit, "en_US"),style: TextStyle(fontSize: width/22,fontWeight: FontWeight.bold,color: Colors.grey),),),
                      ListTile(visualDensity: const VisualDensity(vertical: -4),title:   LocaleText("debit",style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: width/26,fontWeight: FontWeight.bold,color: Colors.grey)),dense: true,trailing: Text(Env.currencyFormat(debit, "en_US"),style: TextStyle(fontSize: width/22,fontWeight: FontWeight.bold,color: Colors.grey),),),
                      ListTile(visualDensity: const VisualDensity(vertical: -4),title:   LocaleText("balance",style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: width/26,fontWeight: FontWeight.bold,color: Colors.grey)),dense: true, trailing: Text(Env.currencyFormat(balance, "en_US"),style: TextStyle(fontSize: width/22,fontWeight: FontWeight.bold,color: balance.toInt()<0?Colors.red.shade900:Colors.green)),),
                    ],
                  ),
                ),
              ),
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
                          onRefresh: endSelectedDate == null ? _onRefresh : _onDateRefresh,
                          child: SizedBox(
                            child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context,index){
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 4),
                                        child: ListTile(
                                          onTap: ()async{
                                           Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionDetails(data: items[index]))).then((value) {
                                             if(value){
                                               _onRefresh();
                                             }
                                           });

                                          },
                                          dense: true,
                                          leading: SizedBox(
                                              height: 40,width: 40,
                                              child: CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage: items[index].pImage!.isNotEmpty? Image.file(File(items[index].pImage!),fit: BoxFit.cover).image:const AssetImage("assets/Photos/no_user.jpg"))),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                                          title: Row(
                                            children: [
                                              Text(items[index].person,style: TextStyle(fontSize: width/28,fontWeight: FontWeight.bold),),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 3),
                                                decoration: BoxDecoration(
                                                    color: items[index].trnCategory == "received"? Colors.lightGreen:Colors.red.shade700,
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: Icon(
                                                  //Paid is debit and received is Credit
                                                  //Means Debit increases amount in person's account and credit decreases
                                                  items[index].trnCategory == "received"? UniconsLine.arrow_down_left:UniconsLine.arrow_up_right, color: Colors.white,size: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(provider.showHidePersianDate? Env.persianDateTimeFormat(DateTime.parse(items[index].createdAt.toString())):Env.gregorianDateTimeForm(items[index].createdAt.toString()),style: const TextStyle(fontSize: smallSize,color: Colors.grey),),
                                          trailing: Column(
                                            children: [

                                              const SizedBox(height: 6),
                                              Expanded(child: Text(Env.currencyFormat(items[index].amount, "en_US"),style: TextStyle(fontSize: width/26,color: items[index].trnCategory == "received"?Colors.green:Colors.red.shade900),)),
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
      ),
    );
  }

  showGregorianPicker()async{
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
        transactions = transactionsByDate;
        _onDateRefresh();
      });
    }
    return dateTimeRange;
  }

  showPersianPicker()async{
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
    if(picked != null){
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


