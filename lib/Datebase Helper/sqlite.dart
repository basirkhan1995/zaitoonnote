import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/note_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/trn_model.dart';
import 'package:zaitoonnote/Screens/Json%20Models/users.dart';
import '../Methods/env.dart';


class DatabaseHelper {
  final databaseName = "zWallet45.db";
  int noteStatus = 1;

  String dirName = "MyBackup";
  String user = "create table users (usrId integer primary key autoincrement,fullName TEXT, phone TEXT, usrName Text UNIQUE, usrPassword Text)";
  String categories = "create table category (cId integer primary key AUTOINCREMENT, cName TEXT NOT NULL,categoryType TEXT) ";
  String notes = "create table notes (noteId integer primary key autoincrement, noteTitle Text NOT NULL,color INTEGER, noteContent Text NOT NULL,noteStatus integer,noteCategory INTEGER, noteImage TEXT,noteCreatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY (noteCategory) REFERENCES category (cId) ON DELETE CASCADE)";
  String persons = "create table persons (pId INTEGER PRIMARY KEY AUTOINCREMENT, pName TEXT, jobTitle TEXT, cardNumber TEXT, accountName TEXT, pImage TEXT,pPhone TEXT,updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)";
  String activities = "create table transactions (trnId INTEGER PRIMARY KEY AUTOINCREMENT, trnDescription TEXT, trnType INTEGER, trnPerson INTEGER NOT NULL, amount REAL NOT NULL, trnImage TEXT,trnDate TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (trnPerson) REFERENCES persons (pId) ON DELETE CASCADE, FOREIGN KEY (trnType) REFERENCES category (cId)ON DELETE CASCADE)";

  //Default Data
  String defaultActivityData = ''' 
  INSERT INTO category (cId, cName, categoryType) values 
  (1,'%', 'activity'),
  (2,'paid', 'activity' ),
  (3,'received', 'activity')
  '''
  ;
  String defaultNoteData = ''' 
  INSERT INTO category (cId, cName, categoryType) values 
  (4,'%', 'note'), 
  (5,'home', 'note'),
  (6,'work', 'note'),
  (7,'personal', 'note'),
  (8,'wishlist', 'note'),
  (9,'birthday','note')
  ''';

  //Future init method to create a database, user table and user default data
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return await openDatabase(path, version: 1, onCreate: (db, version) async {

      await db.execute(user);
      await db.execute(notes);
      await db.execute(persons);
      await db.execute(categories);

      await db.rawQuery(defaultActivityData);
      await db.rawQuery(defaultNoteData);
      await db.execute(activities);

      // Close the database
      await db.close();
    });

  }

  // Future<Directory?> getLocalDirectory() async {
  //   return Platform.isAndroid
  //       ? await getExternalStorageDirectory()
  //       : await getApplicationSupportDirectory();
  // }
  //
  // Future createFolder() async {
  //   final dir = Directory(
  //       '${(Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!.path}$dirName');
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  //   if ((await dir.exists())) {
  //     return dir.path;
  //   } else {
  //     dir.create();
  //     return dir.path;
  //   }
  // }

  getPath()async{
   final directory = await getExternalStorageDirectory();
   final dirPath = '${directory!.path}/Wow';
   await Directory(dirPath).create(recursive: true);
   print(dirPath);
  }



  //SQLITE backup database
  backUpDB(contentType, content, context) async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }
    try {
      final dbPath = await getDatabasesPath();
      var path = join("$dbPath/$databaseName");
      File databasePath = File(path);
      Directory? backUpDestination =
          Directory("/storage/emulated/0/ZaitoonBackup/");
      await backUpDestination.create();

      databasePath.copy("/storage/emulated/0/ZaitoonBackup/$databaseName")
          .whenComplete(() => Env.showSnackBar(
              "backup", "backup_success", contentType, context))
          .onError((error, stackTrace) => Env.showSnackBar(
              "operation_failed", "failed_backup_msg", contentType, context));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  //Browse restore method
  restoreDb(contentType, context) async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }

    try {
      var databasesPath = await getDatabasesPath();
      await FilePicker.platform.clearTemporaryFiles();

      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String recoveryPath = "$databasesPath/$databaseName";
        String newPath = join('${result.files.single.path}');
        File backupFile = File(newPath);
        backupFile.copy(recoveryPath).whenComplete(() => Env.showSnackBar(
                "backup", "backup_restored", contentType, context))
            .onError((error, stackTrace) => Env.showSnackBar(
                "operation_failed", "failed_backup", contentType, context));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception Message: ${e.toString()}");
      }
    }
  }

  //Direct restore method
  restoreDirect(contentType, context) async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;
    if (!status1.isGranted) {
      await Permission.storage.request();
    }

    try {
      var databasesPath = await getDatabasesPath();
      //Direct method to copy
      File newPath = File("/storage/emulated/0/ZaitoonBackup/$databaseName");
      await newPath.copy("$databasesPath/$databaseName").whenComplete(() => Env.showSnackBar(
          "backup", "backup_restored", contentType, context))
          .onError((error, stackTrace) => Env.showSnackBar(
          "operation_failed", "failed_backup", contentType, context));
    } catch (e) {
      if (kDebugMode) {
        print("Exception Message: ${e.toString()}");
      }
    }
  }

  //Delete Db
  deleteDb(contentType, context) async {
    try {
      final dbPath = await getDatabasesPath();
      deleteDatabase(
          "$dbPath/$databaseName").whenComplete(() => Env.showSnackBar(
          "successfully", "records_deleted", contentType, context));
      if (kDebugMode) {
        print("success deleted");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }


  //Auth
  //-----------------------------------------------

  //Login Screen
  Future<bool> authenticateUser(UsersModel user) async {
    final Database db = await initDB();
    var response = await db.rawQuery(
        "select * from users where usrName='${user.usrName}' and usrPassword='${user.usrPassword}'");
    if (response.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<int> createUser(UsersModel user)async{
    final Database db = await initDB();
    var res = await db.insert("users", user.toMap());
    print("New user $res");
    return res;
  }

  Future<UsersModel?> getCurrentUser(int usrId)async{
    final Database db = await initDB();
    var res = await db.query('users',where: 'usrId = ?',whereArgs: [usrId]);
    print("Details: $res");
    return res.isNotEmpty? UsersModel.fromMap(res.first):null;
  }

  //Update note
  Future<int> changePassword(String newPassword, String oldPassword) async {
    final Database db = await initDB();
    var result = await db.rawUpdate(
        "update users set usrPassword = ? where usrPassword = ? ",
        [newPassword, oldPassword]);
    return result;
  }

  //Create a new category
  Future<int> createCategory(CategoryModel category) async {
    final Database db = await initDB();
    return db.insert('category', category.toMap());
  }

  //Get Categories by type
  Future<List<CategoryModel>> getCategories(String type) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.query('category',
        orderBy: 'cId', where: 'categoryType = ?', whereArgs: [type]);
    return queryResult.map((e) => CategoryModel.fromMap(e)).toList();
  }

  //Show Persons
  Future<List<CategoryModel>> getCategoryByType(value) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select * from category where categoryType = ? AND cName != ?",
        [value, "%"]);
    return queryResult.map((e) => CategoryModel.fromMap(e)).toList();
  }

  //Persons --------------------------------------------------------------------

  //Create a new person
  Future<int> createPerson(PersonModel person) async {
    final Database db = await initDB();
    return db.insert('persons', person.toMap());
  }

  //Show Persons
  Future<List<PersonModel>> getPersonByName(filter) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.query('persons',
        orderBy: 'pId', where: 'pName like ?', whereArgs: ["%$filter%"]);
    return queryResult.map((e) => PersonModel.fromMap(e)).toList();
  }

  //Show Persons
  Future<List<PersonModel>> getAllPersons() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('persons', orderBy: 'pId');
    return queryResult.map((e) => PersonModel.fromMap(e)).toList();
  }


  //Update note
  Future<int> updateProfileImage(String image, pId) async {
    final Database db = await initDB();
    var result = await db.rawUpdate(
        "update persons set pImage = ? where pId  = ? ", [image, pId]);
    return result;
  }

  //Update person Details
  Future<int> updateProfileDetails(pName, jobTitle, cardNumber, accountName, pPhone, pId) async {
    final Database db = await initDB();
    var result = await db.rawUpdate(
        "update persons set pName = ?, jobTitle =?, cardNumber = ?, accountName =?, pPhone = ?, updatedAt = ? where pId  = ? ",
        [pName, jobTitle, cardNumber, accountName, pPhone,DateTime.now().toIso8601String(), pId]);
    return result;
  }

  // Delete
  Future<void> deletePerson(String id,context) async {
    final db = await initDB();
    try {
      await db.delete("persons", where: "pId = ?", whereArgs: [id]);
    } catch (err) {
      if (kDebugMode) {
        print("deleting failed: $err");
      }
    }
  }

  //Transactions -----------------------------------------------------------------

  //Create a new transaction
  Future<int> createTransaction(
      String description, int type, int person, double amount, trnImage,date) async {
    final Database db = await initDB();
    return db.rawInsert(
        "insert into transactions (trnDescription, trnType, trnPerson, amount, trnImage, trnDate) values (?,?,?,?,?,?)",
        [description, type, person, amount, trnImage,date]);
  }


  //Show transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId");
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Show transactions
  Future<List<TransactionModel>> getTodayRecentTransactions() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId AND DATE(trnDate) = DATE(?) ORDER BY trnDate DESC LIMIT 5",[DateTime.now().toIso8601String()]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }


  //Show transactions
  Future<List<TransactionModel>> getTodayTransactions(date) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId AND DATE(trnDate) = DATE(?)",[date]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Show transactions
  Future<List<TransactionModel>> getTransactionByNameDate(date) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId WHERE DATE(trnDate) = DATE(?) ",[date]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }


  //Show transactions
  Future<List<TransactionModel>> transactionSearch(String keyword) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where pName LIKE? ",
        ["%$keyword%"]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by type (filtering)
  Future<List<TransactionModel>> filterTransactions(String type) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage,pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where cName LIKE? ",
        ["%$type%"]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by Date Range and Person Id
  Future<List<TransactionModel>> getTransactionByDateRange(String id, first, end) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where b.pId = ? AND date(trnDate) BETWEEN ? AND ? ",
        [id, first, end]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }


  //Transaction By Single Date
  Future<List<TransactionModel>> getTransactionsBySingleDate(int pId , date) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where b.pId = ? AND DATE(trnDate) = DATE(?)",[pId,date]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Show transactions
  Future<List<TransactionModel>> getPersonTodayTransactions(date,person) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId AND DATE(trnDate) = DATE(?) AND pName = ?",[date,person]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by Date Range and Person Id
  Future<List<TransactionModel>> getTransactionDateRange(first, end) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where date(trnDate) BETWEEN ? AND ? ",
        [first, end]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Transaction by Person Id
  Future<List<TransactionModel>> getTransactionByPersonId(String id) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select trnId, cName, trnImage, pImage, trnDescription, pName, amount, trnDate from transactions As a INNER JOIN persons As b ON a.trnPerson = b.pId INNER JOIN category As c ON a.trnType = c.cId where b.pId = ? ",
        [id]);
    return queryResult.map((e) => TransactionModel.fromMap(e)).toList();
  }

  //Update note
  Future<int> updateTransaction(details, double amount, id) async {
    final Database db = await initDB();
    var result = await db.rawUpdate('update transactions set trnDescription = ? ,amount = ? where trnId = ?',[details, amount,id]);
    return result;
  }

  // Delete
  Future<void> deleteTransaction(int id) async {
    final db = await initDB();
    try {
      await db.delete("transactions", where: "trnId = ?", whereArgs: [id]);
    } catch (err) {
      if (kDebugMode) {
        print("deleting failed: $err");
      }
    }
  }


  //Transactions to PDF
  Future<void> transactionToPDF(TransactionModel model)async{
    final pdf = Document();

    pdf.addPage(Page(build: (context)=>Center(child: Text(model.toString()))));

    final directory = await getExternalStorageDirectory();
    final file = File("${directory?.path}/allTransactions.pdf");
    await file.writeAsBytes((await pdf.save()));

  }

  //Notes ----------------------------------------------------------------------

  //Create a new note
  Future<int> createNote(title, content, int category,int color,date) async {
    final Database db = await initDB();
    return db.rawInsert(
        "insert into notes (noteTitle, noteContent, noteStatus, noteCategory, color, noteCreatedAt) values (?,?,$noteStatus,?,?,?)",
        [title, content, category,color,date]);
  }

  //Show incomplete notes with 1 status
  Future<List<Notes>> getNotes() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('notes', orderBy: 'noteId', where: 'noteStatus = 1');
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  //show completed notes with 0 status
  Future<List<Notes>> getFilteredNotes(String category) async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select noteId, noteTitle,color, noteContent, noteStatus, noteCreatedAt, cName , cId from notes As a INNER JOIN category As b ON a.noteCategory = b.cId where cName LIKE ? ",
        ["%$category%"]);
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  //show completed notes with 0 status
  Future<List<Notes>> getAllNotes() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
        "select noteId, noteTitle, noteContent, color, noteStatus, noteCreatedAt, cName,cId from notes As a INNER JOIN category As b ON a.noteCategory = b.cId where b.categoryType = ? ",
        ["note"]);
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  //show pending notes with 0 status
  Future<List<Notes>> getRemovedNotes() async {
    final Database db = await initDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('notes', orderBy: 'noteId', where: 'noteStatus = 0');
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  // Delete
  Future<void> deleteNote(String id) async {
    final db = await initDB();
    try {
      await db.delete("notes", where: "noteId = ?", whereArgs: [id]);
    } catch (err) {
      if (kDebugMode) {
        print("deleting failed: $err");
      }
    }
  }

  //Update note Status to complete
  Future<int> setNoteStatus(int? id) async {
    final Database db = await initDB();
    final res = await db
        .rawUpdate('UPDATE notes SET noteStatus = 0 WHERE noteId = ?', [id]);
    return res;
  }

  //Update note Status to complete
  Future<int> updateNote(title,content,category,date, int? id) async {
    final Database db = await initDB();
    final res = await db
        .rawUpdate('UPDATE notes SET noteTitle = ?, noteContent = ?, noteCategory = ? , noteCreatedAt = ?  WHERE noteId = ?', [title,content,category,date,id]);
    return res;
  }

  //Search by title
  Future<List<Notes>> searchNote(String keyword) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> allRows = await db
        .query('notes', where: 'noteTitle LIKE ?', whereArgs: ['%$keyword%']);
    List<Notes> searchedNote = allRows.map((e) => Notes.fromMap(e)).toList();
    return searchedNote;
  }

  //Filter by category
  Future<List<Notes>> filterNote(String keyword) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> allRows = await db
        .query('notes', where: 'category LIKE ?', whereArgs: ['%$keyword%']);
    List<Notes> searchedNote = allRows.map((e) => Notes.fromMap(e)).toList();
    return searchedNote;
  }

  Future closeDB() async {
    final Database db = await initDB();
    db.close();
  }

  //Reports, Count
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  //Total note count
  Future<int?> totalUsers() async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(
        await db.rawQuery("select count(*) from persons"));
    return count;
  }

  Future<int?> totalAmountToday(int trnType) async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "select sum(amount) from transactions where trnType = ? AND DATE(trnDate) = DATE(?) ",
        [trnType, DateTime.now().toIso8601String()]));
    return count;
  }

  Future<int?> totalSumByCategoryAndPersonByDateRange(
      int trnType, int person, start, end) async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "select sum(amount) from transactions where trnType = ? AND trnPerson = ? AND DATE(trnDate) BETWEEN ? AND ?",
        [trnType, person, start, end]));
    return count;
  }

  Future<int?> totalSumByCategoryAndPerson(
      int trnType, int person) async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "select sum(amount) from transactions where trnType = ? AND trnPerson = ?",
        [trnType, person]));
    return count;
  }


  Future<int?> totalSumByCategoryByDateRange(
      int trnType, start, end) async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "select sum(amount) from transactions where trnType = ? AND DATE(trnDate) BETWEEN ? AND ?",
        [trnType, start, end]));
    return count;
  }

  Future<int?> totalSumByCategory(
      int trnType) async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "select sum(amount) from transactions where trnType = ?",
        [trnType]));
    return count;
  }

 //------------------------------------------------------------ all stats


  Future<int?> totalSumByPersonTransactionAllTimes(int trnType, int person) async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery(
        "select sum(amount) from transactions where trnType = ? AND trnPerson = ?",
        [trnType, person]));
    return count;
  }

  Future totalAmountByCategory (int type)async{
    final Database db = await initDB();
    final result = await db.rawQuery("select sum(amount) as total from transactions where trnType = ?",[type]);
    return result;
  }

  Future totalAmountByCategoryAndPerson (int type,int person)async{
    final Database db = await initDB();
    final result = await db.rawQuery("select sum(amount) as total from transactions where trnType = ? AND trnPerson = ?",[type,person]);
    return result;
  }

  Future totalAmountByCategoryPersonDate (int type,int person,startDate, endDate)async{
    final Database db = await initDB();
    final result = await db.rawQuery("select sum(amount) as total from transactions where trnType = ? AND trnPerson = ? AND DATE(trnDate) BETWEEN ? AND ?",[type,person,startDate,endDate]);
    return result;
  }

  Future totalAmountByCategoryDate (int type,startDate, endDate)async{
    final Database db = await initDB();
    final result = await db.rawQuery("select sum(amount) as total from transactions where trnType = ? AND DATE(trnDate) BETWEEN ? AND ?",[type,startDate,endDate]);
    return result;
  }


}
