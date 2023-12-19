import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Methods/z_field.dart';
import 'package:zaitoonnote/Screens/Json%20Models/users.dart';
import '../../Provider/provider.dart';
import '../Home/start_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final usrName = TextEditingController();
  final password = TextEditingController();
  final confirmPass = TextEditingController();
  bool isVisible = false;
  final db = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const ListTile(
                  subtitle: LocaleText(
                    "signup_message",
                    style: TextStyle(color: Colors.grey),
                  ),
                  title: LocaleText(
                    "get_started",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: zPrimaryColor),
                  ),
                ),
                ZField(
                  title: "name",
                  controller: fullName,
                  icon: Icons.person,
                  isRequire: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "name_required";
                    }
                    return null;
                  },
                ),
                ZField(
                  title: "phone",
                  controller: phone,
                  icon: Icons.call,
                ),
                ZField(
                  title: "username",
                  controller: usrName,
                  icon: Icons.account_circle,
                  isRequire: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return Locales.string(context, "username_required");
                    }
                    return null;
                  },
                ),
                ZField(
                  title: "password",
                  controller: password,
                  icon: Icons.lock,
                  isRequire: true,
                  securePassword: !isVisible,
                  trailing: IconButton(
                    icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: zPrimaryColor),
                    onPressed: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Locales.string(context, "password_required");
                    }
                    return null;
                  },
                ),
                ZField(
                  securePassword: !isVisible,
                  title: "confirm_password",
                  controller: confirmPass,
                  icon: Icons.lock,
                  isRequire: true,
                  trailing: IconButton(
                    icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: zPrimaryColor),
                    onPressed: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return Locales.string(
                          context, "confirm_password_required");
                    } else if (confirmPass.text != password.text) {
                      return Locales.string(context, "passwords_not_match");
                    }
                    return null;
                  },
                ),
                Consumer<MyProvider>(builder: (context, provider, child) {
                  return ZButton(
                    label: "get_started",
                    height: 55,
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        int res = await db.createUser(UsersModel(
                            usrName: usrName.text,
                            usrPassword: password.text,
                            fullName: fullName.text,
                            phone: phone.text));
                        if (res > 0) {
                          provider.setOnboardingOff();
                          UsersModel? usr = await db.getCurrentUser(1);
                          if (!mounted) return;
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BottomNavBar(users: usr)));
                        }
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
