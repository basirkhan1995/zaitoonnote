import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../../Provider/provider.dart';
import '../Activities/create_transaction.dart';
import '../Json Models/category_model.dart';
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
  DateTime? startDate;
  DateTime? endDate;

  late DatabaseHelper handler;
  late Future<List<TransactionModel>> transactions;
  final db = DatabaseHelper();
  var formatter = NumberFormat('#,##,000');
  String now = DateTime.now().toString();
  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    transactions = handler.getByTransactionPerson(widget.data?.pId.toString()??"");
    handler.initDB().whenComplete(() async {
      setState(() {
        transactions = getTrn();
      });
    });
    _onRefresh();
  }


  //Method to get data from database
  Future<List<TransactionModel>> getTrn() async {
    return await handler.getByTransactionPerson(widget.data?.pId.toString()??"");
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getTrn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context, listen: false);
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreateTransaction()));
        },
      ),
      body:  SafeArea(
        child: Column(
          children: [

            //filter
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -4),
              title: SizedBox(
                width: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: DropdownSearch<CategoryModel>(
                    popupProps: PopupPropsMultiSelection.modalBottomSheet(
                      fit: FlexFit.loose,
                      title: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.zero,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8),
                            height: 5,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                BorderRadius
                                    .circular(15)),
                          ),
                        ],
                      ),

                    ),

                    asyncItems: (value) => db.getCategories("activity"),
                    itemAsString: (CategoryModel u) =>
                        Locales.string(context, u.cName??""),
                    onChanged: (CategoryModel? data) {
                      setState(() {
                        selectedCategoryId = data!.cId!.toInt();
                        selectedCategoryName = data.cName.toString();
                        transactions = db.filterTransactions(selectedCategoryName);
                      });
                    },
                    dropdownButtonProps: const DropdownButtonProps(
                      icon: Icon(Icons.filter_alt_rounded, size: 22),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                          hintStyle: const TextStyle(fontSize: 13),
                          hintText: Locales.string(
                              context, "select_category"),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                          border: InputBorder.none),
                    ),
                  ),
                ),
              ),
              trailing: IconButton(
                onPressed: (){
                  setState(() {
                    datePicker();
                  });
                },
                icon: Icon(Icons.date_range),
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
                                        subtitle: Text(provider.showHidePersianDate? Env.persianDateTimeFormat(DateTime.parse(items[index].createdAt??"")):Env.gregorianDateTimeForm(DateTime.parse(items[index].createdAt??"")),style: const TextStyle(),),
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

  datePicker()async{
    final picked = await showDateRangePicker(
      context: context,
      lastDate: DateTime(2030),
      firstDate: DateTime(2010),
    );
    if (picked != null) {
      print(picked);
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        print("startDate: $startDate");
        print("endDate: $endDate");
      });
    }
  }

}


