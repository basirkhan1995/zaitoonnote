import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import '../../Datebase Helper/sqlite.dart';
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

  late DatabaseHelper handler;
  late Future<List<TransactionModel>> transactions;
  final db = DatabaseHelper();
  var formatter = NumberFormat('#,##,000');

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

  var filterTitles = [
    ""
  ];

  @override
  Widget build(BuildContext context) {
    print("Hellooo ${widget.data?.pId.toString()??"Empty Data"}");
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

            //Search TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
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
                  ),

                  //Filter Button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 10),
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: DropdownSearch<CategoryModel>(
                          popupProps: PopupPropsMultiSelection.modalBottomSheet(
                            fit: FlexFit.loose,
                            title: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  height: 5,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius:
                                      BorderRadius
                                          .circular(15)),
                                ),

                              ],
                            ),

                          ),

                          asyncItems: (value) => db.getCategoryByType("activity"),
                          itemAsString: (CategoryModel u) =>
                              Locales.string(context, u.cName),
                          onChanged: (CategoryModel? data) {
                            setState(() {
                              //selectedCategoryId = data!.cId!.toInt();
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
                  ),
                ],
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
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0,vertical: 4),
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 10),
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      height: 90,
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple.shade900.withOpacity(.8),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.white,
                                              blurRadius: 1,
                                              offset: Offset(1, 0),
                                            ),
                                          ]
                                      ),
                                      child: ListTile(
                                        leading: SizedBox(
                                            height: 60,width: 60,
                                            child: CircleAvatar(
                                                radius: 50,
                                                backgroundImage: items[index].pImage!.isNotEmpty? Image.file(File(items[index].pImage!),fit: BoxFit.cover,).image:const AssetImage("assets/Photos/no_user.jpg"))),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                        title: Text(items[index].person,style:const TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                                        subtitle: Text(items[index].trnDescription,style: const TextStyle(color: Colors.white),),
                                        trailing: Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                child: LocaleText(
                                                  items[index].trnCategory,
                                                  style: const TextStyle(
                                                      color: Colors.deepPurple, fontSize: 13),
                                                ),
                                              ),
                                            ),
                                            Expanded(child: Text(formatAmount(items[index].amount.toString()),style: const TextStyle(fontSize: 20,color: Colors.white),)),
                                          ],
                                        ),

                                      )),
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

  String formatAmount(value){
    String price = value;
    String priceInText = "";
    int counter = 0;
    for(int i = (price.length - 1);  i >= 0; i--){
      counter++;
      String str = price[i];
      if((counter % 3) != 0 && i !=0){
        priceInText = "$str$priceInText";
      }else if(i == 0 ){
        priceInText = "$str$priceInText";

      }else{
        priceInText = ",$str$priceInText";
      }
    }
    return priceInText.trim();
  }


}
