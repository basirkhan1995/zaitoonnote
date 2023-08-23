import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Methods/z_field.dart';
import 'package:zaitoonnote/Provider/provider.dart';
import 'package:zaitoonnote/Screens/Home/start_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
          children: [
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

            Consumer<MyProvider>(
              builder: (context,provider,child) {
                return ListTile(
                  title: const LocaleText("remember_me"),
                  leading: Checkbox(
                    value: provider.rememberMe,
                    onChanged: (value){
                      provider.setRememberMe();
                      provider.storeSharedPreferences();
                    },
                  ),
                );
              }
            ),

            ZButton(
              label: "login",
              onTap:(){
               if(formKey.currentState!.validate()){
                 if(username.text == "admin" && password.text == "123"){
                   Env.goto(BottomNavBar(), context);
                 }
               }
              },
              width: .95,
            ),
          ],
        ),
            )),
      ),
    );
  }
}