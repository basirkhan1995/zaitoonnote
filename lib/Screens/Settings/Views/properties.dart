import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

import '../../../Provider/provider.dart';

class AppProperties extends StatefulWidget {
  const AppProperties({super.key});

  @override
  State<AppProperties> createState() => _AppPropertiesState();
}

class _AppPropertiesState extends State<AppProperties> {
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText("properties"),
      ),

      body: SingleChildScrollView(
        child: Consumer<MyProvider>(
          builder: (context,provider,child) {
            return Column(
              children: [

                ListTile(
                  leading: Switch(
                      value: provider.enableDisableLogin,
                      onChanged: (value){
                        provider.enableLoginPage();
                      }),
                  title: const LocaleText("show_login"),
                  trailing: LocaleText(provider.enableDisableLogin.toString(),style: const TextStyle(fontSize: 16),),
                ),



              ],
            );
          }
        ),
      ),
    );
  }
}
