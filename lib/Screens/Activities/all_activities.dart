import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Screens/Activities/transaction_details.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../../Provider/provider.dart';
import '../Json Models/trn_model.dart';
import 'create_transaction.dart';


class AllActivities extends StatefulWidget {
  const AllActivities({super.key});

  @override
  State<AllActivities> createState() => _AllActivitiesState();
}

class _AllActivitiesState extends State<AllActivities> {
  final searchCtrl = TextEditingController();
  String keyword = "";
  String noteTypeCategory = "activity";
  late DatabaseHelper handler;
  late Future<List<TransactionModel>> transactions;
  late Future<List<CategoryModel>> category;

  final db = DatabaseHelper();
  var formatter = NumberFormat('#,##,000');
  DateTime? date;
  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    transactions = handler.getTransactions();
    handler.initDB().whenComplete(() async {
      setState(() {
        transactions = getTrn();
        category = handler.getCategories(noteTypeCategory);

      });
    });
    _onRefresh();
  }


  //Method to get data from database
  Future<List<TransactionModel>> getTrn() async {
    return await handler.getTransactions();
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getTrn();
      category = getCategories();
    });
  }

  //Method to get category from database
  Future<List<CategoryModel>> getCategories() async {
    return await handler.getCategories(noteTypeCategory);
  }

  int currentFilterIndex = 0;



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

            //Filter buttons
            SizedBox(
              height: 50,
              child: FutureBuilder<List<CategoryModel>>(
                  future: category,
                  builder: (BuildContext context, AsyncSnapshot<List<CategoryModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                      //If snapshot has error
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return const SizedBox();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      //a final variable (item) to hold the snapshot data
                      final items = snapshot.data ?? <CategoryModel>[];
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            splashColor: Colors.transparent,
                            onTap: (){
                              setState(() {
                                currentFilterIndex = index;
                               transactions = db.filterTransactions(items[index].cName??"");
                              });
                            },
                            child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  color: currentFilterIndex == index? Colors.deepPurple.withOpacity(.5): Colors.deepPurple.withOpacity(.1),
                                ),
                                child: Center(
                                  child: LocaleText(
                                    items[index].cName??"",
                                    style: TextStyle(
                                        color: currentFilterIndex == index? Colors.white: Colors.deepPurple,
                                        fontSize: 14,
                                        fontWeight: currentFilterIndex == index? FontWeight.bold: FontWeight.w400),
                                  ),
                                )),
                          );
                        },
                      );
                    }
                  }
              ),
            ),

            //Search TextField
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8)
              ),
              child: TextFormField(
                controller: searchCtrl,
                onChanged: (value){
                  setState(() {
                    keyword = searchCtrl.text;
                    transactions = db.transactionSearch(keyword);
                  });
                },
                decoration: InputDecoration(
                    hintText: Locales.string(context,"search"),
                    icon: const Icon(Icons.search),
                    border: InputBorder.none
                ),
              ),
            ),

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
                            // MaterialButton(
                            //   shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(4)),
                            //   minWidth: 100,
                            //   color: Theme.of(context).colorScheme.inversePrimary,
                            //   onPressed: () => _onRefresh(),
                            //   child: const LocaleText("refresh"),
                            // )
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
                              itemBuilder: (context,index){
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 0),
                                  child: ListTile(
                                    onTap: ()=> Env.goto(TransactionDetails(data: items[index]), context),
                                    leading: SizedBox(
                                        height: 60,width: 60,
                                        child: CircleAvatar(
                                          radius: 50,
                                            backgroundImage: items[index].pImage!.isNotEmpty? Image.file(File(items[index].pImage!),fit: BoxFit.cover,).image:const AssetImage("assets/Photos/no_user.jpg"))),
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
                                    subtitle: Text(provider.showHidePersianDate? Env.persianDateTimeFormat(DateTime.parse(items[index].createdAt.toString())):Env.gregorianDateTimeForm(items[index].createdAt.toString())),
                                    trailing: Text(Env.amountFormat(items[index].amount.toString()),style: const TextStyle(fontSize: 18),),
                                    dense: true,
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
  


}
