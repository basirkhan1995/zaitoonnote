import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Methods/z_field.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'dart:io';
import '../../Datebase Helper/sqlite.dart';

class AddPerson extends StatefulWidget {
  const AddPerson({super.key});

  @override
  State<AddPerson> createState() => _AddPersonState();
}

class _AddPersonState extends State<AddPerson> {
  final phone = TextEditingController();
  final fullName = TextEditingController();
  final jobTitle = TextEditingController();
  final cardNumber = TextEditingController();
  final cardName = TextEditingController();

  File? _pImage;
  final db = DatabaseHelper();
  var image;
  @override
  void initState() {
    _pImage = _pImage;
    super.initState();
  }

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ZButton(
              radius: 6,
              width: .4,
              onTap: () {
                if (formKey.currentState!.validate()) {
                  db.createPerson(PersonModel(
                      pName: fullName.text,
                      pPhone: phone.text,
                      cardNumber: cardNumber.text,
                      accountName: cardName.text,
                      jobTitle: jobTitle.text,
                      createdAt: DateTime.now().toIso8601String(),
                      updatedAt: DateTime.now().toIso8601String(),
                      pImage: _pImage?.path ?? ""))
                      .whenComplete((){
                    Navigator.of(context).pop(true);
                  });
                }
                print(_pImage?.path);
              },
              label: "create",
              backgroundColor: zPrimaryColor,
            ),
          ),
        ],
        title: const LocaleText("new_account"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      getImage(ImageSource.gallery);
                      getImage1(ImageSource.gallery);
                    },
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: zPrimaryColor,
                      child: CircleAvatar(
                        radius: 68,
                        backgroundImage: _pImage != null
                            ? Image.file(_pImage!, fit: BoxFit.cover).image
                            : const AssetImage("assets/Photos/no_user.jpg"),
                      ),
                    ),
                  ),
                  ZField(
                      isRequire: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return Locales.string(context, "name_required");
                        }
                        return null;
                      },
                      inputAction: TextInputAction.next,
                      title: "name",
                      icon: Icons.person,
                      controller: fullName),
                  ZField(

                      inputAction: TextInputAction.next,
                      title: "phone",
                      icon: Icons.phone,
                      controller: phone,
                      keyboardInputType: TextInputType.phone),
                  ZField(
                      inputAction: TextInputAction.next,
                      title: "job",
                      icon: Icons.work,
                      controller: jobTitle,
                      keyboardInputType: TextInputType.text),
                  ZField(
                      title: "card_number",
                      inputAction: TextInputAction.next,
                      icon: Icons.credit_card,
                      controller: cardNumber,
                      keyboardInputType: TextInputType.number),
                  ZField(
                      inputAction: TextInputAction.done,
                      title: "account_name",
                      icon: Icons.person,
                      controller: cardName,
                      keyboardInputType: TextInputType.text),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getImage1(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);

    final appDocDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDocDir.path}/backup');
    final originalDir = Directory('${appDocDir.path}/original');

    // Create backup directory
    if (!await backupDir.exists()) {
      await backupDir.create();
    }

    // Create original directory
    if (!await originalDir.exists()) {
      await originalDir.create();
    }

    if (pickedFile == null) return;
    setState(() {
      _pImage = File(pickedFile.path);
    });

    final newFile = File('${appDocDir.path}/${_pImage?.path.split('/').last}');
    newFile.copy(backupDir.path);

    print("New path: $newFile");
    print("Dir: $backupDir");

  }



  Future<void> getImage(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) return;
    setState(() {
      _pImage = File(pickedFile.path);
    });
  }



}
