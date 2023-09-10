import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Provider/provider.dart';
import 'package:zaitoonnote/Screens/Settings/Views/accounts.dart';
import 'package:zaitoonnote/Screens/Settings/Views/change_password.dart';
import 'package:zaitoonnote/Screens/Settings/Views/general_reports.dart';
import 'package:zaitoonnote/Screens/Settings/Views/properties.dart';
import 'package:zaitoonnote/Screens/Settings/Views/themes.dart';
import 'package:zaitoonnote/Screens/Settings/Views/db_backup.dart';
import '../../Methods/env.dart';
import 'Views/about_app.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     double width = MediaQuery.of(context).size.width;
    final controller = Provider.of<MyProvider>(context, listen: false);
    String currentLocale = Locales.currentLocale(context).toString();
    List items = [
      "accounts",
      "themes",
      "properties",
      "backup",
      "reports",
      "about"
    ];
    List subItems = [
      "accdetails",
      "themesdetails",
      "show or hide properties",
      "backup_data",
      "general_reports",
      "about"
    ];

    List icons = [
      Icons.person_rounded,
      Icons.color_lens,
      Icons.settings_rounded,
      Icons.backup,
      Icons.query_stats,
      Icons.info
    ];
    List pages = <Widget>[
      const AccountSettings(),
      const ChangeThemes(),
      const AppProperties(),
      const DatabaseBackup(),
      const GeneralTransactionReports(),
      const AboutApp(),
    ];
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          actions: const [
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 30.0),
              child: Icon(Icons.settings)
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        horizontalTitleGap: 15,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => pages[index]));
                        },
                        title: LocaleText(
                          items[index],
                          style: TextStyle(fontSize: width/25,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
                        ),
                        subtitle: LocaleText(subItems[index],style: TextStyle(fontSize: width/28,color: Colors.grey,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),),
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

                        trailing: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(.09),
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(Icons.arrow_forward_ios_rounded,
                                size: normalSize)),
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
                  subtitle: LocaleText(Locales.currentLocale(context).toString(),style: TextStyle(fontSize: width/28,color: Colors.grey),),
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
                  title: LocaleText(
                    "language",
                    style: TextStyle(fontSize: width/25,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
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
                        title: LocaleText(
                          "change_password",
                          style: TextStyle(fontSize: width/25,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
                        ),
                        subtitle: LocaleText("change_password_hint",style: TextStyle(fontSize: width/28,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",color: Colors.grey),),
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
                        title: LocaleText(
                          "logout",
                          style: TextStyle(fontSize: width/25,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
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
    double width = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              title: LocaleText("language",style: TextStyle(fontSize: width/22,fontWeight:FontWeight.bold),),
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
