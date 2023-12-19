import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zaitoonnote/Methods/colors.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));

    String locale = Locales.currentLocale(context).toString();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: zPrimaryColor.withOpacity(.7),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(70))),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .35,
                child: Image.asset(
                  "assets/Photos/wallet.png",
                  width: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListTile(
                  title: Text(
                    "zWallet",
                    style: TextStyle(
                        fontFamily: "Ubuntu",
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width / 18),
                  ),
                  subtitle: const Text("Version: 1.4.0",
                      style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 13,
                          color: Colors.grey)),
                  visualDensity: const VisualDensity(vertical: -4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                    softWrap: true,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: MediaQuery.of(context).size.width / 25,
                            fontFamily: locale == "en" ? "Ubuntu" : "Dubai"),
                        children: [
                          TextSpan(text: Locales.string(context, "about_app")),
                        ])),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const ListTile(
                        leading: Icon(
                          UniconsLine.at,
                          size: 40,
                        ),
                        title: LocaleText(
                          "email",
                          style: TextStyle(fontFamily: "Ubuntu"),
                        ),
                        subtitle: Text(
                          "info@zaitoon.tech",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Ubuntu"),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(UniconsLine.whatsapp_alt, size: 40),
                        subtitle: const Text("+93790128308"),
                        title: const Text(
                          "WhatsApp",
                          style: TextStyle(fontFamily: "Ubuntu"),
                        ),
                        onTap: () => _openWhatsApp(),
                      ),
                      ListTile(
                        title: const Text(
                          "Github",
                          style: TextStyle(fontFamily: "Ubuntu"),
                        ),
                        leading: const Icon(
                          UniconsLine.github,
                          size: 40,
                        ),
                        onTap: () => _openGithub(),
                      ),
                      ListTile(
                        title: const Text(
                          "Facebook",
                          style: TextStyle(fontFamily: "Ubuntu"),
                        ),
                        leading: const Icon(
                          Icons.facebook,
                          size: 40,
                        ),
                        onTap: () {
                          _openFacebook();
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Future<void> _openFacebook() async {
    Uri facebook = Uri.parse("https://www.facebook.com/mohammadbasir.1995");
    launchUrl(facebook);
    await launchUrl(facebook);
  }

  Future<void> _openGithub() async {
    Uri github = Uri.parse("https://github.com/basirkhan1995");
    launchUrl(github);
    await launchUrl(github);
  }

  Future<void> _openWhatsApp() async {
    Uri whatsApp = Uri.parse("https://wa.me/+93790128308");
    launchUrl(whatsApp);
    await launchUrl(whatsApp);
  }
}
