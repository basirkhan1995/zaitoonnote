import 'package:flutter/material.dart';

import '../../Datebase Helper/sqlite.dart';

class PersonReports extends StatefulWidget {
  const PersonReports({super.key});

  @override
  State<PersonReports> createState() => _PersonReportsState();
}

class _PersonReportsState extends State<PersonReports> {

  late DatabaseHelper handler;

  final db = DatabaseHelper();


  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();

    handler.initDB().whenComplete(() async {
      setState(() {

      });
    });
    _onRefresh();
  }


  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {

    });
  }

  /*
  //Total Users count
  Future<int?> total()async{
    int? count = await handler.totalNotes();
    setState(() => totalNotes = count!);
    return totalNotes;
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Total categories"),
      ),
      body: Text("reports"),
    );
  }
}
