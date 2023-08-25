import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:zaitoonnote/Provider/provider.dart';
import 'package:zaitoonnote/Screens/Settings/Views/accounts.dart';
import 'package:zaitoonnote/Screens/Settings/Views/change_password.dart';
import 'package:zaitoonnote/Screens/Settings/Views/properties.dart';
import 'package:zaitoonnote/Screens/Settings/Views/themes.dart';
import 'package:zaitoonnote/Screens/Settings/backup/db_backup.dart';
import '../../Methods/env.dart';
import '../About App/about_app.dart';
import 'Views/individuals_records.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MyProvider>(context, listen: false);
    List items = [
      "accounts",
      "themes",
      "reports",
      "properties",
      "backup",
      "about"
    ];
    List subItems = [
      "accdetails",
      "themesdetails",
      "report_details",
      "show or hide properties",
      "backup_data",
      "about"
    ];

    List icons = [
      Icons.person_rounded,
      Icons.color_lens,
      Icons.insert_chart,
      Icons.settings_rounded,
      Icons.backup,
      Icons.info
    ];
    List pages = <Widget>[
      const AccountSettings(),
      const ChangeThemes(),
      const IndividualsRecords(),
      const AppProperties(),
      const DatabaseBackup(),
      const AboutApp(),
    ];
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          actions:  [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: InkWell(
                onTap: (){

                },
                child: const CircleAvatar(
                  backgroundImage: AssetImage("assets/Photos/no_user.jpg"),
                ),
              ),
            )
          ],
          title: const LocaleText("settings"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        horizontalTitleGap: 15,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => pages[index]));
                        },
                        subtitle: LocaleText(subItems[index]),
                        leading: Container(
                          margin: const EdgeInsets.all(0),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.deepPurple.withOpacity(.09)),
                          child: Icon(
                            icons[index],
                            color: Colors.deepPurple,
                            size: 24,
                          ),
                        ),
                        title: LocaleText(
                          items[index],
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(.09),
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 12)),
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  horizontalTitleGap: 15,
                  onTap: () {
                    switchLanguage(context);
                  },
                  subtitle: LocaleText(Locales.currentLocale(context).toString()),
                  leading: Container(
                    margin: const EdgeInsets.all(0),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.deepPurple.withOpacity(.09)),
                    child: const Icon(
                      Icons.language,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                  title: const LocaleText(
                    "language",
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(.09),
                          borderRadius: BorderRadius.circular(50)),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 12)),
                ),
              ),

              controller.enableDisableLogin? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        horizontalTitleGap: 15,
                        onTap: () {
                          Env.goto(const ChangePassword(), context);
                        },
                        leading: Container(
                          margin: const EdgeInsets.all(0),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.deepPurple.withOpacity(.09)),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.deepPurple,
                            size: 24,
                          ),
                        ),
                        title: const LocaleText(
                          "change_password",
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: const LocaleText("change_password_hint"),
                        trailing: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(.09),
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(Icons.arrow_forward_ios_rounded, size: 12)),
                      ),
              ):const SizedBox(),
              controller.enableDisableLogin? Consumer<MyProvider>(
                  builder: (context,provider,child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        horizontalTitleGap: 15,
                        onTap: () {
                          provider.logout(context);
                        },
                        leading: Container(
                          margin: const EdgeInsets.all(0),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.deepPurple.withOpacity(.09)),
                          child: const Icon(
                            Icons.logout_outlined,
                            color: Colors.deepPurple,
                            size: 24,
                          ),
                        ),
                        title: const LocaleText(
                          "logout",
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(.09),
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(Icons.arrow_forward_ios_rounded, size: 12)),
                      ),
                    );
                  }
              ):const SizedBox(),
            ],
          ),
        ));
  }

  void switchLanguage(context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              title: const LocaleText("language"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    splashColor: Colors.transparent,
                    onTap: () {
                      Locales.change(context, 'fa');
                      Navigator.pop(context);
                    },
                    title: const Text("فارسی"),
                    leading: const Icon(Icons.language),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_outlined, size: 14),
                  ),
                  ListTile(
                    splashColor: Colors.transparent,
                    onTap: () {
                      Locales.change(context, 'en');
                      Navigator.pop(context);
                    },
                    title: const Text("English"),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 14,
                    ),
                    leading: const Icon(Icons.language),
                  ),
                ],
              ),
            ));
  }
}
