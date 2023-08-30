
 import 'package:flutter/cupertino.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';

class SqliteProvider with ChangeNotifier{
  final db = DatabaseHelper();

  void createTransaction(description, type, person, amount, trnImage, date){
   db.createTransaction(description, type, person, amount, trnImage, date);
    notifyListeners();
  }

  
 }