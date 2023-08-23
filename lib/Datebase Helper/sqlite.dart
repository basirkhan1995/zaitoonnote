import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/note_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/trn_model.dart';
import 'dart:io';

class DatabaseHelper{

  final databaseName = "club.db";
  int noteStatus = 1;
  String user = "create table users (usrId integer primary key autoincrement, usrName Text UNIQUE, usrPassword Text)";
  String categories = "create table category (cId integer primary key AUTOINCREMENT, cName TEXT NOT NULL,categoryType TEXT, catCreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP) ";
  String notes = "create table notes (noteId integer primary key autoincrement, noteTitle Text NOT NULL, noteContent Text NOT NULL,noteStatus integer,noteCategory INTEGER, noteImage TEXT,noteCreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY (noteCategory) REFERENCES category (cId))";
  String persons = "create table persons (pId INTEGER PRIMARY KEY AUTOINCREMENT, pName TEXT, jobTitle TEXT, cardNumber TEXT, accountName TEXT, pImage TEXT,pPhone TEXT,updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)";
  String activities = "create table transactions (trnId INTEGER PRIMARY KEY AUTOINCREMENT, trnDescription TEXT, trnType INTEGER, trnPerson INTEGER NOT NULL, amount INTEGER NOT NULL, trnImage TEXT, trnDate TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (trnPerson) REFERENCES persons (pId), FOREIGN KEY (trnType) REFERENCES category (cId))";

  //Default Data
  String defaultActivityData = "INSERT INTO category (cId, cName, categoryType) values (1,'%', 'activity'),(2,'paid', 'activity' ),(3,'received', 'activity'),(4,'check', 'activity'),(5,'rent', 'activity'),(6,'power', 'activity')";
  String defaultNoteData = "INSERT INTO category (cId, cName, categoryType) values (8,'%', 'note'), (9,'home', 'note'),(10,'work', 'note'),(11,'personal', 'note'),(12,'wishlist', 'note'),(13,'birthday','note')";
  String userData = "insert into users (usrId, usrName, usrPassword) values(1,'admin','123456')";

  //Future init method to create a database, user table and user default data
  Future <Database> initDB()async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return await openDatabase(path,version: 1, onCreate: (db,version)async{
      await db.execute('PRAGMA foreign_keys = ON');
      //auto execute the user table into the database
      await db.execute(user);
      //auto execute the user default data in the table
      await db.rawQuery(userData);
      await db.execute(notes);
      await db.execute(persons);
      await db.execute(categories);
      await db.rawQuery(defaultActivityData);
      await db.rawQuery(defaultNoteData);
      await db.execute(activities);
    });
  }


  
  

  //SQLITE backup
   backUpDB()async{

    var status = await Permission.manageExternalStorage.status;
   if(!status.isGranted){
     await Permission.manageExternalStorage.request();
   }
   var status1 = await Permission.storage.status;
   if(!status1.isGranted){
     await Permission.storage.request();
   }
   try{

     File ourDBFile = File("/data/user/0/com.example.zaitoonnote/databases/$databaseName");
     Directory? folderPathForDbFile = Directory("/storage/emulated/0/ZaitoonBackup/");
     await folderPathForDbFile.create();
     ourDBFile.copy("/storage/emulated/0/ZaitoonBackup/$databaseName");

   }catch(e){
     print("Exception Message: ${e.toString()}");
   }
  }

  restoreDb ()async{
    var status = await Permission.manageExternalStorage.status;
    if(!status.isGranted){
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if(!status1.isGranted){
      await Permission.storage.request();
    }

    try{
      // File ourDBFile = File("/data/user/0/com.example.zaitoonnote/databases/$databaseName");
      //   var databasesPath = await getDatabasesPath();
      //  FilePickerResult? result = await FilePicker.platform.pickFiles();
      //   if (result != null) {
      //    File source = File(result.files.single.path!);
      //   var result2 = await source.copy("$databasesPath/$databaseName");
      //    print("Heeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee : $result2");
      //   } else {
      //     print("user canceled permission");
      //   }

      File savedFile = File("/storage/emulated/0/ZaitoonBackup/$databaseName");
      await savedFile.copy("/data/user/0/com.example.zaitoonnote/databases/$databaseName");
    }catch(e){
      print("Exception Message: ${e.toString()}");
    }
  }

  //Delete Db

  deleteDb()async{
    try{
      deleteDatabase("/data/user/0/com.example.zaitoonnote/databases/$databaseName");
      print("success deleted");
    }catch(e){
      print("Exception Message: ${e.toString()}");
    }
  }

  getDbPath()async{
    final databasePath = await getDatabasesPath();
    print("-----------------Database Path: $databasePath");
    Directory? externalStoragePath = await getExternalStorageDirectory();
    print("-----------------External Stroage Path: $externalStoragePath");
  }

  //Create a new category
  Future <int> createCategory(CategoryModel category)async{
    final Database db = await initDB();
    return db.insert('category', category.toMap());
  }


  //Get Categories by type
  Future<List<CategoryModel>> getCategories (String type) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('category',orderBy: 'cId',where: 'categoryType = ?' ,whereArgs: [type]);
    return queryResult.map((e) => CategoryModel.fromMap(e)).toList();
  }

  //Show Persons
  Future <List<CategoryModel>> getCategoryByType (value) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select * from category where categoryType = ? AND cName != ?",[value,"%"]);
    return queryResult.map((e) => CategoryModel.fromMap(e)).toList();
  }




  //Persons --------------------------------------------------------------------

  //Create a new person
  Future <int> createPerson(PersonModel person)async{
    final Database db = await initDB();
    return db.insert('persons', person.toMap());
  }

  //Show Persons
  Future <List<PersonModel>> getPersonsByID ( filter) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('persons',orderBy: 'pId',where: 'pName like ?', whereArgs: ["%$filter%"]);
    return queryResult.map((e) => PersonModel.fromMap(e)).toList();
  }

  //Show Persons
  Future <List<PersonModel>> getPersons () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('persons',orderBy: 'pId');
    return queryResult.map((e) => PersonModel.fromMap(e)).toList();
  }

  //Show transactions
  Future <List<PersonModel>> personSearch (String keyword) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select pId, pName, pImage, pPhone, createdAt from persons where pName LIKE? ",["%$keyword%"]);
    return queryResult.map((e) => PersonModel.fromMap(e)).toList();
  }

  //Update note
  Future <int> updateProfileImage(String image, pId)async{
    final Database db = await initDB();
    var result = await db.rawUpdate("update persons set pImage = ? where pId  = ? ",[image,pId]);
    return result;
  }

  //Update note
  Future <int> updateProfileDetails(pName,jobTitle,cardNumber,accountName,pPhone,updatedAt, pId)async{
    final Database db = await initDB();
    var result = await db.rawUpdate("update persons set pName = ?, jobTitle =?, cardNumber = ?, accountName =?, pPhone = ?, updatedAt = ? where pId  = ? ",[pName,jobTitle, cardNumber, accountName,pPhone, updatedAt, pId]);
    return result;
  }


  //Transactions -----------------------------------------------------------------

  //Create a new transaction
  Future <int> createTransaction(TransactionModel transaction)async{
    final Database db = await initDB();
    return db.insert('transactions', transaction.toMap());
  }

  //Create a new transaction
  Future <int> createTransaction2(String description, int type, int person, int amount, trnImage)async{
    final Database db = await initDB();
    return db.rawInsert("insert into transactions (trnDescription, trnType, trnPerson, amount, trnImage) values (?,?,?,?,?)", [description, type, person, amount, trnImage]);
  }

  //Show transactions
  Future <List<TransactionModel>> getTransactions () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId ORDER BY trnId");
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }
  //Show transactions
  Future <List<TransactionModel>> transactionSearch (String keyword) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where pName LIKE? ",["%$keyword%"]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by type (filtering)
  Future <List<TransactionModel>> filterTransactions (String type) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select trnId, cName, trnImage,pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where cName LIKE? ",["%$type%"]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by type (filtering)
  Future <List<TransactionModel>> getByTransactionPerson (String id) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where b.pId = ? ", [id]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by type (filtering)
  Future <List<TransactionModel>> getTransactionsByDate (String date) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select trnId, cName, trnImage,pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where trnDate = ? ",["%$date%"]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Notes ----------------------------------------------------------------------

  //Create a new note
  Future <int> createNote(title, content,int category,image)async{
    final Database db = await initDB();
    return db.rawInsert("insert into notes (noteTitle, noteContent, noteStatus,noteCategory, noteImage) values (?,?,$noteStatus,?,?)", [title, content, category, image]);
  }

  //Show incomplete notes with 1 status
  Future <List<Notes>> getNotes () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('notes',orderBy: 'noteId',where: 'noteStatus = 1');
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  //show completed notes with 0 status
  Future <List<Notes>> getFilteredNotes (String category) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select noteId, noteTitle, noteContent, noteStatus, noteCreatedAt, cName, noteImage from notes As a INNER JOIN category As b ON a.noteCategory = b.cId where cName = ? ",["%$category%"]);
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  //show completed notes with 0 status
  Future <List<Notes>> getAllNotes() async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select noteId, noteTitle, noteContent, noteStatus, noteCreatedAt, cName, noteImage from notes As a INNER JOIN category As b ON a.noteCategory = b.cId where b.categoryType = ? ",["note"]);
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  //show pending notes with 0 status
  Future <List<Notes>> getRemovedNotes () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('notes',orderBy: 'noteId',where: 'noteStatus = 0');
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }


  // Delete
  Future<void> deleteNote(String id) async {
    final db = await initDB();
    try {
      await db.delete("notes", where: "noteId = ?", whereArgs: [id]);
    } catch (err) {
      if (kDebugMode){
        print("deleting failed: $err");
      }
    }
  }

  //Update note
  Future <int> updateNotes(Notes note)async{
    final Database db = await initDB();
    var result = await db.update('notes', note.toMap(), where: 'noteId = ?', whereArgs: [note.noteId]);
    return result;
  }



  //Update note Status to complete
  Future <int> setNoteStatus(int? id)async{
    final Database db = await initDB();
    final res = await db.rawUpdate('UPDATE notes SET noteStatus = 0 WHERE noteId = ?', [id]);
    return res;
  }

  //Search by title
  Future<List<Notes>> searchMemo(String keyword)async{
    final Database db = await initDB();
    List<Map<String,dynamic>> allRows = await db.query('notes',where: 'noteTitle LIKE ?',whereArgs: ['%$keyword%']);
    List<Notes> searchedNote = allRows.map((e) => Notes.fromMap(e)).toList();
    return searchedNote;
  }

  //Filter by category
  Future<List<Notes>> filterMemo(String keyword)async{
    final Database db = await initDB();
    List<Map<String,dynamic>> allRows = await db.query('notes',where: 'category LIKE ?',whereArgs: ['%$keyword%']);
    List<Notes> searchedNote = allRows.map((e) => Notes.fromMap(e)).toList();
    return searchedNote;
  }
  Future closeDB ()async{
    final Database db = await initDB();
    db.close();
  }

  //Reports, Count
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  //Total note count
  Future <int?> totalNotes() async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery("select count(*) from notes"));
    return count;
  }

  Future <int?> totalCategory() async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery("select count (*) from notes where category group by category"));
    return count;
  }


  Future <int?> categoryCounts() async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery("select cName, count (cId) from transactions group by cName ORDER BY COUNT(cId) DESC"));
    return count;
  }


}

