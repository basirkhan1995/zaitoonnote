import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Methods/z_field.dart';

import '../../../Methods/env.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final formKey = GlobalKey<FormState>();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  void changePass(context)async{
    final db = DatabaseHelper();
    int result = await db.changePassword(newPassword.text,oldPassword.text);
    if(result>0){
      newPassword.clear();
      oldPassword.clear();
      confirmPassword.clear();
      Env.showSnackBar2("operation_success", "password_change_success_message", ContentType.success,context);
    }else{
      Env.showSnackBar2("operation_failed", "password_change_failed_message", ContentType.success,context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const LocaleText("change_password"),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.lock,size: 80,color: zPrimaryColor),
                ZField(title: "current_password",controller: oldPassword,icon: Icons.lock),
                ZField(title: "new_password",controller: newPassword,icon: Icons.lock),
                ZField(title: "confirm_password",controller: confirmPassword,icon: Icons.lock,validator: (value){
                  if(newPassword.text != confirmPassword.text){
                    return "Password_not_matched";
                  }
                  return null;
                },),
                ZButton(
                  onTap: ()async{
                   if(formKey.currentState!.validate()){
                   changePass(context);
                   }
                  },
                  label: "update",
                  width: .9,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
