import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Methods/colors.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: zPrimaryColor.withOpacity(.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50)
                    )
                  ),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height *.35,
                 child: Image.asset("assets/Photos/wallet.png"),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Version: 1.0.0+1",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                      softWrap:true,
                      textAlign:TextAlign.justify,
                      text: TextSpan(
                          style: const TextStyle(color: Colors.black87),
                          children:[
                            TextSpan(text:Locales.string(context, "about_app")),

                          ])),
                ),

                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ListTile(
                          title: LocaleText("email"),
                          subtitle: Text(
                            "info@zaitoon.tech",style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          title: LocaleText("whatsapp"),
                          subtitle: Text(
                            "+93790128308",style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          "Developed by",style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            "Basir Hashimi"
                        ),
                        Text(
                            "©2023"
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )

        );
      }
}



