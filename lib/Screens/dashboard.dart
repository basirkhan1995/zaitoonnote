import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        title: const LocaleText("dashboard"),
      ),
    );
  }
}
