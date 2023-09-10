import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Home/start_screen.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Persons/add_person.dart';
import 'package:zaitoonnote/Screens/Settings/Views/individuals_records.dart';
import '../../../Datebase Helper/sqlite.dart';
import '../../../Methods/env.dart';
import 'dart:io';


class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final db = DatabaseHelper();

  late DatabaseHelper handler;
  late Future<List<PersonModel>> accounts;

  final searchCtrl = TextEditingController();
  String keyword = "";

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    accounts = handler.getAllPersons();
    handler.initDB().whenComplete(() async {
      setState(() {
        accounts = getAllPersons();
      });
    });
    _onRefresh();
  }


  //Method to get data from database
  Future<List<PersonModel>> getAllPersons() async {
    return await handler.getAllPersons();
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      accounts = getAllPersons();
    });
  }
  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    String locale = Locales.currentLocale(context).toString();
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText("accounts"),
        leading: IconButton(
          onPressed: ()=> Env.goto(const BottomNavBar(), context), icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [

          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: zPrimaryColor,
            ),
            child: IconButton(
                onPressed: (){
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddPerson())).then((value) {
                   if(value){
                     _onRefresh();
                   }
                 });
                }, icon: const Icon(Icons.add,color: Colors.white)),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: zPrimaryColor,
            ),
            child: IconButton(
                onPressed: (){
                  setState(() {
                    isSearch = !isSearch;
                  });
                }, icon: const Icon(Icons.search,color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [

            //Search TextField
          isSearch? Container(
              margin: const EdgeInsets.symmetric(horizontal: 14,vertical: 8),
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
                    accounts = db.getPersonByName(keyword);
                  });
                },
                decoration: InputDecoration(
                    hintText: Locales.string(context,"search"),
                    icon: const Icon(Icons.search),
                    border: InputBorder.none
                ),
              ),
            ):const SizedBox(),

            Expanded(
              child: FutureBuilder<List<PersonModel>>(
                future: accounts,
                builder: (BuildContext context, AsyncSnapshot<List<PersonModel>> snapshot) {
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
                    final items = snapshot.data ?? <PersonModel>[];
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
                                        onTap: ()=> Env.goto(IndividualsRecords(data: items[index],), context),
                                        leading: SizedBox(
                                            height: 60,width: 60,
                                            child: CircleAvatar(
                                                radius: 50,
                                                backgroundImage: items[index].pImage!.isNotEmpty? Image.file(File(items[index].pImage!),fit: BoxFit.cover,).image:const AssetImage("assets/Photos/no_user.jpg"))),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 18),
                                        dense: true,
                                        title: Text(items[index].pName??"",style: TextStyle(color: zPrimaryColor,fontSize: 16,fontWeight: FontWeight.bold,fontFamily: locale == "en"?"Ubuntu":"Dubai"),),
                                        subtitle: Text(items[index].pPhone.toString(),style:  TextStyle(color: zGrey,fontFamily: locale == "en"?"Ubuntu":"Dubai"),),
                                        trailing: const Icon(Icons.arrow_forward_ios_outlined,size: 15,color: zPrimaryColor),

                                      ),
                                    ),
                                    Divider(endIndent: 25,indent: 25,color: Colors.grey.withOpacity(.25),height: 1,)
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
