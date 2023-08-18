import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/note_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/trn_model.dart';


class DatabaseHelper{

  final databaseName = "memo987.db";

  String userTable = "create table users (usrId integer primary key autoincrement, usrName Text UNIQUE, usrPassword Text)";
  String userData = "insert into users (usrId, usrName, usrPassword) values(1,'admin','123456')";
  String category = "create table category (cId integer primary key AUTOINCREMENT, cName TEXT UNIQUE NOT NULL, createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP) ";
  String notes = "create table notes (noteId integer primary key autoincrement, noteTitle Text NOT NULL, noteContent Text NOT NULL,noteStatus integer,category TEXT, noteImage TEXT,createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)";
  String persons = "create table persons (pId INTEGER PRIMARY KEY AUTOINCREMENT, pName TEXT,createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)";
  String trn = "create table transactions (trnId INTEGER PRIMARY KEY AUTOINCREMENT, trnDescription TEXT, trnType TEXT NOT NULL, trnPerson INTEGER NOT NULL, amount INTEGER NOT NULL, trnImage TEXT, trnDate TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (trnPerson) REFERENCES persons (pId))";
  String defaultCategories = "INSERT INTO category (cId, cName) values (1,'%'),(2,'paid'),(3,'received'),(4,'power'),(5,'rent')";

  //Future init method to create a database, user table and user default data
  Future <Database> initDB()async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return await openDatabase(path,version: 1, onCreate: (db,version)async{
      await db.execute('PRAGMA foreign_keys = ON');
      //auto execute the user table into the database
      await db.execute(userTable);
      //auto execute the user default data in the table
      await db.rawQuery(userData);
      await db.execute(notes);
      await db.execute(persons);
      await db.execute(category);
      await db.rawQuery(defaultCategories);
      await db.execute(trn);
    });
  }

  //Create a new category
  Future <int> createCategory(CategoryModel category)async{
    final Database db = await initDB();
    return db.insert('category', category.toMap());
  }


  //Show Persons
  Future<List<CategoryModel>> getCategories () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('category',orderBy: 'cId');
    return queryResult.map((e) => CategoryModel.fromMap(e)).toList();
  }


  //Show Persons
  Future <List<CategoryModel>> getCategoryById (value) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('category',orderBy: 'cId',where: 'cName like ?', whereArgs: ["%$value%"]);
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

  //Transactions -----------------------------------------------------------------

  //Create a new transaction
  Future <int> createTransaction(TransactionModel transaction)async{
    final Database db = await initDB();
    return db.insert('transactions', transaction.toMap());
  }

  //Create a new transaction
  Future <int> createTransaction2(String description, String category, int person, int amount)async{
    final Database db = await initDB();
    return db.rawInsert("insert into transactions (trnDescription, trnType, trnPerson, amount ) values (?,?,?,?)", [description, category, person, amount]);
  }

  //Show transactions
  Future <List<TransactionModel>> getTransactions () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select trnId, trnType, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId ORDER BY trnId");
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }
  //Show transactions
  Future <List<TransactionModel>> transactionSearch (String keyword) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select trnId, trnType, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId where pName LIKE? ",["%$keyword%"]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by type (filtering)
  Future <List<TransactionModel>> filterTransactions (String type) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.rawQuery("select trnId, trnType, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId where trnType LIKE? ",["%$type%"]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by type (filtering)
  Future <List<TransactionModel>> getByTransactionPerson (String type) async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('transactions',where: 'trnCategory = ?',whereArgs: [type]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }


  //Notes ----------------------------------------------------------------------

  //Create a new note
  Future <int> createNote(Notes note)async{
    final Database db = await initDB();
    return db.insert('notes', note.toMap());
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
    final List<Map<String, Object?>>  queryResult = await db.query('notes',where: 'category = ?',whereArgs: [category]);
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
}