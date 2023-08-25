import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
import 'package:zaitoonnote/Methods/z_button.dart';


class DatabaseBackup extends StatefulWidget {
  const DatabaseBackup({super.key});

  @override
  State<DatabaseBackup> createState() => _DatabaseBackupState();
}

class _DatabaseBackupState extends State<DatabaseBackup> {
  final db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const LocaleText("backup"),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/Photos/backup2.jpg")
                  )
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: ListTile(
                title: LocaleText("backup"),
                subtitle: LocaleText("backup_hint"),
                ),
              ),


              const SizedBox(height: 10),
              // ZButton(
              //   width: .9,
              //   label: "open_backup",
              //   onTap: (){
              //     db.getDbPath();
              //   },
              // ),

              ZButton(
                width: .9,
                label: "backup",
                onTap: (){
                  db.backUpDB(ContentType.success,context);
                },
              ),
              // ZButton(
              //   width: .9,
              //   label: "delete db",
              //   onTap: (){
              //     db.deleteDb();
              //   },
              // ),
              // ZButton(
              //   width: .9,
              //   label: "get path",
              //   onTap: (){
              //     db.backUp();
              //   },
              // ),

              ZButton(
                width: .9,
                label: "restore_backup",
                onTap: (){
                  db.restoreDb(ContentType.success,context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}




