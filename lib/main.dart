import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:zaitoonnote/Screens/Authentications/login.dart';
import 'Provider/provider.dart';
import 'Screens/Home/start_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ));
  Locales.init(['en', 'fa']);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => MyProvider()..initialize(),
      child: Consumer<MyProvider>(
        builder: (context, MyProvider notifier,child){
          final controller = Provider.of<MyProvider>(context, listen: false);
          return LocaleBuilder(
              builder: (locale) =>
                  MaterialApp(
                    themeMode: controller.darkLight? ThemeMode.dark: ThemeMode.light,
                    darkTheme: controller.darkLight? ThemeData.dark() : ThemeData.light(),
                    title: 'Zaitoon Note',
                    localizationsDelegates: Locales.delegates,
                    supportedLocales: Locales.supportedLocales,
                    locale: locale,
                    debugShowCheckedModeBanner: false,
                    theme:
                    ThemeData(
                      buttonTheme: const ButtonThemeData(
                      ),
                      fontFamily: "Dubai",
                      appBarTheme: const AppBarTheme(
                        titleSpacing: 0,
                        titleTextStyle: TextStyle(fontSize: 18,color: Colors.black,fontFamily: "Dubai",),
                        iconTheme: IconThemeData(
                          size: 19,
                        ),
                        elevation: 0,
                      ),
                      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                      useMaterial3: true,
                    ),
                    home: controller.rememberMe? const BottomNavBar(): controller.enableDisableLogin? const LoginPage() : const BottomNavBar(),
                  )
          );},
      ),
    );
  }
}