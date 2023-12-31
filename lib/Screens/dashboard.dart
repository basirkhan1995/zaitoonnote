import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Screens/Json%20Models/users.dart';
import 'package:zaitoonnote/Screens/Settings/Views/accounts.dart';
import '../Datebase Helper/sqlite.dart';
import '../Methods/colors.dart';
import '../Methods/env.dart';
import '../Methods/z_button.dart';
import '../Provider/provider.dart';
import 'Activities/create_transaction.dart';
import 'Json Models/trn_model.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'Notes/create_note.dart';
import 'Persons/add_person.dart';

class Dashboard extends StatefulWidget {
  final UsersModel? usr ;
  const Dashboard({super.key,this.usr});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  final db = DatabaseHelper();
  late DatabaseHelper handler;
  late Future<List<TransactionModel>> transactions;

  double totalPaid = 0 ;
  double totalReceived = 0;
  int totalUser = 0;

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
  Future<int> totalUsers()async{
    int? count = await handler.totalUsers();
    setState(() => totalUser = count??0);
    return totalUser;
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      transactions = getTransactions();
      totalUsers();
      totalCredit();
      totalDebit();
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<double> totalCredit()async{
    double? total = (await db.totalAmountByCategory(3))[0]['total'];
    setState(() {
      totalReceived = total??0;
    });
    return totalReceived;
  }

  Future<double> totalDebit()async{
    double? total = (await db.totalAmountByCategory(2))[0]['total'];
    setState(() {
      totalPaid = total??0;
    });
    return totalPaid;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final provider = Provider.of<MyProvider>(context, listen: false);
    var currentLocale = Locales.currentLocale(context).toString();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                dense: true,
                horizontalTitleGap: 6,
                leading: provider.enableDisableLogin?const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/Photos/no_user.jpg"),
                  ),
                ):null,
                title: const LocaleText("welcome", style: TextStyle(fontSize: 16),),
                trailing: Text(currentLocale == "en" ?DateFormat('MEd').format(DateTime.now()): Env.persianFormatWithWeekDay(Jalali.now()),style: TextStyle(fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: mediumSize),),
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 0),
                height: 150,
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

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    //Total Users
                   Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Column(
                         children: [
                           InkWell(
                             child: CircularPercentIndicator(
                                  radius: 40.0,
                                  lineWidth: 5.0,
                                  animation: true,
                                  percent: 0.3,
                                  center:  Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: zPrimaryColor.withOpacity(.15)
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 30.0,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  backgroundColor: zPrimaryColor.withOpacity(.3),
                                  progressColor: Colors.purple,
                                ),
                             onTap: (){
                               Navigator.push(context, MaterialPageRoute(builder: (context)=>const AccountSettings()));
                             },
                           ),
                           const SizedBox(height: 8),
                           Text(totalUser.toString(),style: TextStyle(fontSize: width/22,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),),
                            LocaleText("accounts",style: TextStyle(fontSize: mediumSize,fontFamily: currentLocale == "en" ? "Ubuntu":"Dubai"),),
                         ],
                       ),
                     ],
                   ),

                    //Total Debit
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 40.0,
                          lineWidth: 5.0,
                          animation: true,
                          percent: .4,
                          center:  Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.red.withOpacity(.1)
                            ),
                            child: const Icon(
                              UniconsLine.arrow_up_right,
                              size: 30.0,
                              color: Colors.red,
                            ),
                          ),
                          backgroundColor: Colors.red.withOpacity(.3),
                          progressColor: Colors.red.shade900,
                        ),
                        const SizedBox(height: 8),
                        Text(Env.currencyFormat(totalPaid, "en_US"),style: TextStyle(fontSize: width/22,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),),
                         LocaleText("debit",style: TextStyle(fontSize: mediumSize,fontFamily: currentLocale == "en" ? "Ubuntu":"Dubai"),),
                      ],
                    ),

                    //Total Credit
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 40.0,
                          lineWidth: 5.0,
                          animation: true,
                          percent: .5,
                          center:  Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.green.withOpacity(.1)
                            ),
                            child: const Icon(
                              UniconsLine.arrow_down_left,
                              size: 30.0,
                              color: Colors.green,
                            ),
                          ),
                          backgroundColor: Colors.green.withOpacity(.3),
                          progressColor: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text(Env.currencyFormat(totalReceived, "en_US"),style: TextStyle(fontSize: width/22,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),),
                         LocaleText("credit",style: TextStyle(fontSize: mediumSize,fontFamily: currentLocale == "en" ? "Ubuntu":"Dubai"),),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    height: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 8,vertical: 2),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ZButton(
                                    backgroundColor: zPrimaryColor,
                                    width: .92,
                                    label: "create_note",
                                    labelColor: Colors.white,
                                    onTap: ()=>Env.goto(const CreateNote(), context),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: ZButton(
                                    labelColor: Colors.white,
                                    backgroundColor: zPrimaryColor,
                                    width: .92,
                                    label: "add_activity",
                                    onTap: ()async{
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
                                ),

                              ],
                            ),
                          ),
                          ZButton(
                            labelColor: Colors.white,
                            backgroundColor: zPrimaryColor,
                            width: .92,
                            height: 50,
                            label: "add_account",
                            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddPerson())).then((value) {
                              if(value){
                                _onRefresh();
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              //Recent Transaction
              Container(
                padding: const EdgeInsets.symmetric(vertical: 0),
                height: MediaQuery.of(context).size.height *.43,
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

                child: Column(
                  children: [
                    ListTile(
                      horizontalTitleGap: 6,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      trailing: const Icon(UniconsLine.transaction),
                      leading: const Icon(Icons.access_time),
                      title: LocaleText("recent_activities",style: TextStyle(fontSize: normalSize, color: Colors.grey,fontWeight: FontWeight.bold,fontFamily: currentLocale.toString() == "en"?"Ubuntu":"Dubai"),),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 350,
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
                                        Image.asset("assets/Photos/empty.png",width: 150),
                                      ],
                                    ));
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                //a final variable (item) to hold the snapshot data
                                final items = snapshot.data ?? <TransactionModel>[];
                                return SizedBox(
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
                                                    Text(items[index].person,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),),
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
                                                subtitle: Text(currentLocale != "en" ? Env.persianDateTimeFormat(DateTime.parse(items[index].createdAt.toString())):Env.gregorianDateTimeForm(items[index].createdAt.toString())),
                                                trailing: Text(Env.currencyFormat(items[index].amount, "en_US"),style: TextStyle(fontSize: width/24,color: items[index].trnCategory == "received"?Colors.green:Colors.red.shade900,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontWeight: FontWeight.bold),),
                                                dense: true,
                                              ),
                                            ),
                                            Divider(endIndent: 15,indent: 15,color: Colors.grey.withOpacity(.25),height: 1)
                                          ],
                                        );
                                      }),
                                );
                              }
                            },
                          ),
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


}

