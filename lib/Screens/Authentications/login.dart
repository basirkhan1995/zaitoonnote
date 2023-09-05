
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Methods/z_field.dart';
import 'package:zaitoonnote/Provider/provider.dart';
import 'package:zaitoonnote/Screens/Home/start_screen.dart';
import 'package:zaitoonnote/Screens/Json%20Models/users.dart';
import '../../Methods/custom_drop_down.dart';
import '../../Methods/env.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String selectedValue = "";
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MyProvider>(context, listen: false);
    return Scaffold(
      body: Form(
        key: formKey,
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                          color: zPrimaryColor.withOpacity(.2),
                          borderRadius: BorderRadius.circular(10)),
                      child: CustomDropDown(
                        items: const [
                          CustomDropdownMenuItem(
                              value: "en",
                              child: Text("English")
                          ),
                          CustomDropdownMenuItem(
                            value: "fa",
                            child: Text("فارسی"),
                          ),

                        ],
                        hintText: Locales.string(context, context.currentLocale.toString()),
                        borderRadius: 5,
                        onChanged: (val) {
                          setState(() {
                            selectedValue = val;
                            controller.switchLanguage(context, selectedValue);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.width / 2,
                          width: MediaQuery.of(context).size.width * .7,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage("assets/Photos/login_bg.jpg"))),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: ListTile(
                            title: LocaleText(
                              "login",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: LocaleText("login_hint"),
                          ),
                        ),
                        ZField(
                          controller: username,
                          title: "username",
                          icon: Icons.account_circle,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Locales.string(context, "username_required");
                            }
                            return null;
                          },
                        ),
                        ZField(
                          controller: password,
                          title: "password",
                          icon: Icons.lock,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Locales.string(context, "password_required");
                            }
                            return null;
                          },
                        ),
                        Consumer<MyProvider>(builder: (context, provider, child) {
                          return ListTile(
                            horizontalTitleGap: 0,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                            title: const LocaleText("remember_me"),
                            leading: Checkbox(
                              value: provider.rememberMe,
                              onChanged: (value) {
                                provider.setRememberMe();
                              },
                            ),
                          );
                        }),
                        Consumer<MyProvider>(builder: (context, provider, child) {
                          return ZButton(
                            label: "login",
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                var db = DatabaseHelper();
                                var result = await db.authenticateUser(UsersModel(
                                    usrName: username.text,
                                    usrPassword: password.text));
                                if (result == true) {
                                  if (controller.rememberMe == true) {
                                    controller.setLoginTrue();
                                  }
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const BottomNavBar()));
                                } else {
                                  if (!mounted) return;
                                  Env.showSnackBar2(
                                      "access_denied",
                                      "access_denied_message",
                                      ContentType.failure,
                                      context);
                                  if (kDebugMode) {
                                    print(result);
                                  }
                                  if (kDebugMode) {
                                    print("username and password are incorrect");
                                  }
                                }
                              }
                            },
                            width: .91,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        )),
      ),
    );
  }
}
