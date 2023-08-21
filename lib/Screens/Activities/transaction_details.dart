import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Screens/Json%20Models/trn_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../Json Models/note_model.dart';

class TransactionDetails extends StatefulWidget {
  final TransactionModel? data;
  const TransactionDetails({super.key, this.data});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  final db = DatabaseHelper();
  bool isUpdate = false;
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  var dropValue = 0;

  late DatabaseHelper handler;
  late Future<List<Notes>> notes;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    notes = handler.getNotes();
    handler.initDB().whenComplete(() async {
      setState(() {
        notes = getList();
      });
    });
  }

  //Method to get data from database
  Future<List<Notes>> getList() async {
    return await handler.getNotes();
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      notes = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.parse(widget.data!.createdAt.toString());

    //Gregorian Date format
    final gregorianDate = DateFormat('yyyy/MM/dd - HH:mm a').format(dt);
    Jalali persianDate = dt.toJalali();

    //Persian Date format
    String shamsiDate() {
      final f = persianDate.formatter;
      return '${f.yyyy}/${f.mm}/${f.dd}';
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,

        title: Text(widget.data!.person),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: LocaleText(
                "date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              dense: true,
              title: Container(
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.deepPurple.withOpacity(.3)),
                  child: Text(
                    gregorianDate,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  )),
              subtitle: Text(
                shamsiDate(),
                style: const TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),

            widget.data!.trnImage!.isNotEmpty
                ? InkWell(
              onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Scaffold( body: Center(
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20.0),
                  minScale: 0.1,
                  maxScale: 1.6,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: Image.file(
                              File(widget.data!.trnImage.toString()),
                              fit: BoxFit.cover).image,
                        )
                    ),
                  ),
                ),
              ),))),
                  child: Container(
                      width: MediaQuery.of(context).size.width *.95,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image:Image.file(
                            File(widget.data!.trnImage.toString()),
                            fit: BoxFit.cover).image
                        )
                      ),
                  ),
                ):const SizedBox(),

          ],
        ),
      ),
    );
  }
}








