import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Persons/person_transactions.dart';
import 'package:zaitoonnote/Screens/Persons/profile.dart';
import 'package:zaitoonnote/Screens/Persons/reports.dart';

class IndividualsRecords extends StatefulWidget {
  final PersonModel? data;
  const IndividualsRecords({super.key,this.data});

  @override
  State<IndividualsRecords> createState() => _IndividualsRecordsState();
}

class _IndividualsRecordsState extends State<IndividualsRecords> {

  @override
  Widget build(BuildContext context) {
    String currentLocale = Locales.currentLocale(context).toString();
    return Scaffold(
        body: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                unselectedLabelStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",color: Colors.grey),
                labelStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: Locales.string(context,"profile"),),
                  Tab(text: Locales.string(context,"activity"),),
                  Tab(text: Locales.string(context,"report"),),
                ],
              ),
              title: Text(widget.data?.pName??""),
            ),
            body: TabBarView(
              children: [
                PersonProfile(profileDetails: widget.data),
                PersonActivities(data: widget.data),
                PersonReports(person: widget.data),
              ],
            ),
          ),
        ),
    );
  }
}
