import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Screens/Notes/create_note.dart';
import 'package:zaitoonnote/Screens/Persons/add_person.dart';
import 'dart:io';
import '../Datebase Helper/sqlite.dart';
import '../Methods/colors.dart';
import '../Methods/env.dart';
import '../Provider/provider.dart';
import 'Activities/create_transaction.dart';
import 'Json Models/trn_model.dart';

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
  late Future<List<TransactionModel>> transactions;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    transactions = handler.getTodayRecentTransactions();
    handler.initDB().whenComplete(() async {
      setState(() {
       transactions = getTransactions();
      });
    });
    _onRefresh();
  }

  //Method to get data from database
  Future<List<TransactionModel>> getTransactions() async {
    return await handler.getTodayRecentTransactions();
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
      transactions = getTransactions();
      users();
      received();
      paid();
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context, listen: false);
    var currentLocale = Locales.currentLocale(context).toString();
    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 ListTile(
                   dense: true,
                   horizontalTitleGap: 6,
                   leading: provider.enableDisableLogin?Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 0.0),
                     child: InkWell(
                       onTap: (){
                        showDialog(context: context, builder: (context){
                         return AlertDialog(
                            title: const LocaleText("logout_title"),
                            content: const LocaleText("logout_msg"),
                            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            actions: [
                             Row(
                               children: [
                                 Expanded(
                                   child: ZButton(
                                     label: "yes",
                                     onTap: (){
                                       provider.logout(context);
                                     },
                                   ),
                                 ),
                                 const SizedBox(width: 6),
                                 Expanded(
                                   child: ZButton(
                                     label: "no",
                                     onTap: (){
                                       Navigator.pop(context);
                                     },
                                   ),
                                 ),
                               ],
                             )
                            ],
                          );
                        });
                       },
                       child: const CircleAvatar(
                         backgroundImage: AssetImage("assets/Photos/no_user.jpg"),
                       ),
                     ),
                   ):null,
                   title: LocaleText("welcome",style: TextStyle(fontFamily: currentLocale.toString() == "en"?"Ubuntu":"Dubai",fontSize: 16),),
                  trailing: Text(DateFormat('MMMMEEEEd').format(DateTime.now()),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20,fontFamily: "Ubuntu"),),
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

                 ListTile(
                   horizontalTitleGap: 6,
                   leading: const Icon(Icons.add_circle_outline_sharp),
                   contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 0),
                  title: LocaleText("actions",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey,fontFamily: currentLocale.toString() == "en"?"Ubuntu":"Dubai"),),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ZButton(
                        backgroundColor: Colors.blueGrey.withOpacity(.3),
                        width: .92,
                        label: "create_note",
                        labelColor: Colors.black87,
                        onTap: ()=>Env.goto(const CreateNote(), context),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ZButton(
                        labelColor: Colors.black87,
                        backgroundColor: Colors.blueGrey.withOpacity(.3),
                        width: .92,
                        label: "add_activity",
                        onTap: ()=>Env.goto(const CreateTransaction(), context),
                      ),
                    ),

                  ],
                ),
              ),
                ZButton(
                  labelColor: Colors.black87,
                  backgroundColor: Colors.blueGrey.withOpacity(.3),
                  width: .92,
                  label: "add_account",
                  onTap: ()=>Env.goto(const AddPerson(), context),
                ),

                ListTile(
                  horizontalTitleGap: 6,
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  trailing: Icon(UniconsLine.transaction),
                  leading: Icon(Icons.access_time),
                  title: LocaleText("recent_activities",style: TextStyle( color: Colors.grey,fontWeight: FontWeight.bold,fontFamily: currentLocale.toString() == "en"?"Ubuntu":"Dubai"),),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 300,
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
                                                leading: SizedBox(
                                                    height: 40,width: 40,
                                                    child: CircleAvatar(
                                                        radius: 50,
                                                        backgroundImage: items[index].pImage!.isNotEmpty? Image.file(File(items[index].pImage!),fit: BoxFit.cover,).image:const AssetImage("assets/Photos/no_user.jpg"))),
                                                contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),

                                                title: Row(
                                                  children: [
                                                    Text(items[index].person,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),),
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
                )
              ],
            ),
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
