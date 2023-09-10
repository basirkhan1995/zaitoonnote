import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
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

  void changePass(context) async {
    final db = DatabaseHelper();
    int result = await db.changePassword(newPassword.text, oldPassword.text);
    if (result > 0) {
      newPassword.clear();
      oldPassword.clear();
      confirmPassword.clear();
      Navigator.pop(context);
      Env.showSnackBar("operation_success", "password_change_success_message",
          ContentType.success, context);
    } else {
      Env.showSnackBar("operation_failed", "password_change_failed_message",
          ContentType.success, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText("change_password"),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width / 2,
                    width: MediaQuery.of(context).size.width * .7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/Photos/loginbg.jpg"))),
                  ),
                  ZField(
                    title: "current_password",
                    controller: oldPassword,
                    icon: Icons.lock,
                    validator: (value) {
                      if (value.isEmpty) {
                        return Locales.string(context, "old_password_required");
                      }
                      return null;
                    },
                  ),
                  ZField(
                      title: "new_password",
                      controller: newPassword,
                      icon: Icons.lock,
                      validator: (value) {
                        if (value.isEmpty) {
                          return Locales.string(context, "password_required");
                        }
                        return null;
                      }),
                  ZField(
                    title: "confirm_password",
                    controller: confirmPassword,
                    icon: Icons.lock,
                    validator: (value) {
                      if (value.isEmpty) {
                        return Locales.string(
                            context, "confirm_password_required");
                      } else if (newPassword.text != confirmPassword.text) {
                        return Locales.string(context, "Password_not_matched");
                      }
                      return null;
                    },
                  ),
                  ZButton(
                    height: 55,
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
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
      ),
    );
  }
}
