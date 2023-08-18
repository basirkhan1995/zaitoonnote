import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class Reports extends StatelessWidget {
  const Reports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LocaleText("reports"),
      ),
    );
  }
}
