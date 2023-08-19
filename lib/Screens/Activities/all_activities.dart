import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import '../../Datebase Helper/sqlite.dart';
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

  late DatabaseHelper handler;
  late Future<List<TransactionModel>> transactions;
  final db = DatabaseHelper();
  var formatter = NumberFormat('#,##,000');

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    transactions = handler.getTransactions();
    handler.initDB().whenComplete(() async {
      setState(() {
        transactions = getTrn();
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
    });
  }


  var filterTitle = [
    "all",
    "paid",
    "received",
    "debt",
    "removed"
  ];
  var filterData = [
    "%",
    "paid",
    "received",
    "debt",
    "removed"
  ];
  int currentFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
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
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filterTitle.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,index){
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0,vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: currentFilterIndex==index? Colors.deepPurple.withOpacity(.1):Colors.transparent,
                      ),
                      child: TextButton(
                          onPressed: (){
                            setState(() {
                              currentFilterIndex = index;
                              transactions = db.filterTransactions(filterData[currentFilterIndex]);
                            });
                          },
                          child: LocaleText(filterTitle[index])),
                    );
                  }),
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
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 20),
                                    title: Text(items[index].person.toString(),style:const TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
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
