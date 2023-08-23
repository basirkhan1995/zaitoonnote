import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text("Back up"),
      ),

      body: Center(
        child: Column(
          children: [
            ZButton(
              width: .9,
              label: "get db path",
              onTap: (){
                db.getDbPath();
              },
            ),

            ZButton(
              width: .9,
              label: "back up db",
              onTap: (){
                db.backUpDB();
              },
            ),
            ZButton(
              width: .9,
              label: "delete db",
              onTap: (){
                db.deleteDb();
              },
            ),
            ZButton(
              width: .9,
              label: "open db",
              onTap: (){
                db.restoreDb();
              },
            ),
          ],
        ),
      ),
    );
  }
}
