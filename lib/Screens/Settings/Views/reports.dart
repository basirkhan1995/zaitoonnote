import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Persons/person_transactions.dart';
import 'package:zaitoonnote/Screens/Persons/profile.dart';
import 'package:zaitoonnote/Screens/Persons/reports.dart';

class Reports extends StatefulWidget {
  final PersonModel? data;
  const Reports({super.key,this.data});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
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
                PersonReports(),
              ],
            ),
          ),
        ),
    );
  }
}
