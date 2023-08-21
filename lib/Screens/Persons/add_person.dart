import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _pImage;
  final db = DatabaseHelper();

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       title: const LocaleText("new_account"),
     ),
      body: SafeArea(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15),
                InkWell(
                  splashColor: Colors.transparent,
                  onTap: (){
                   getImage(ImageSource.gallery);
                  },
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: zPurple,
                    child: CircleAvatar(
                      radius: 88,
                     backgroundImage: _pImage!=null? Image.file(_pImage!,fit: BoxFit.cover).image:const AssetImage("assets/Photos/no_user.jpg"),
                    ),
                  ),
                ),
                  ZField(
                    isRequire: true,
                    validator: (value){
                      if(value.isEmpty){
                        return Locales.string(context,"name_required");
                      }
                      return null;
                    },
                    title: "name",icon: Icons.person,controller: fullName,),
                  ZField(title: "phone",icon: Icons.phone,controller: phone ,keyboardInputType: TextInputType.phone),
                  ZButton(
                    onTap: (){
                     if(formKey.currentState!.validate()){
                       db.createPerson(PersonModel(pName: fullName.text, pPhone: phone.text, pImage: _pImage?.path??"")).whenComplete(() => Navigator.pop(context));
                     }
                    },
                    label: "create",
                    backgroundColor: zPurple,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future <void> getImage(ImageSource imageSource)async{
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile == null)return;
    setState((){
      _pImage = File(pickedFile.path);
      print(_pImage);
    });
  }

}
