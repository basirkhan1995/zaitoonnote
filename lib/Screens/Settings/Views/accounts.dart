import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Persons/add_person.dart';
import 'package:zaitoonnote/Screens/Settings/Views/reports.dart';
import '../../../Datebase Helper/sqlite.dart';
import '../../../Methods/env.dart';
import 'dart:io';


class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final searchCtrl = TextEditingController();
  String keyword = "";

  late DatabaseHelper handler;
  late Future<List<PersonModel>> persons;
  final db = DatabaseHelper();
  var formatter = NumberFormat('#,##,000');

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    persons = handler.getPersons();
    handler.initDB().whenComplete(() async {
      setState(() {
        persons = getAllPersons();
      });
    });
    _onRefresh();
  }


  //Method to get data from database
  Future<List<PersonModel>> getAllPersons() async {
    return await handler.getPersons();
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      persons = getAllPersons();
    });
  }
  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText("accounts"),
        actions: [

          Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: zPurpleColor,
            ),
            child: IconButton(
                onPressed: (){
                  Env.goto(const AddPerson(), context);
                }, icon: const Icon(Icons.add,color: Colors.white)),
          ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: zPurpleColor,
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
          isSearch?  Container(
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
                    persons = db.personSearch(keyword);
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
                future: persons,
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
                    final items = snapshot.data ?? <PersonModel>[];
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
                                  child: ListTile(
                                    onTap: ()=> Env.goto(Reports(data: items[index],), context),
                                    leading: SizedBox(
                                        height: 60,width: 60,
                                        child: CircleAvatar(
                                            radius: 50,
                                            backgroundImage: items[index].pImage!.isNotEmpty? Image.file(File(items[index].pImage!),fit: BoxFit.cover,).image:const AssetImage("assets/Photos/no_user.jpg"))),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 18),
                                    dense: true,
                                    title: Text(items[index].pName,style: const TextStyle(color: zPurpleColor,fontSize: 16,fontWeight: FontWeight.bold),),
                                    subtitle: Text(items[index].pPhone.toString(),style: const TextStyle(color: zGrey),),
                                    trailing: const Icon(Icons.arrow_forward_ios_outlined,size: 15,color: zPurpleColor)

                                  ),
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
