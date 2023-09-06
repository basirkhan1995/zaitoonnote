import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import '../../../Provider/provider.dart';


class ChangeThemes extends StatefulWidget {
  const ChangeThemes({super.key});

  @override
  State<ChangeThemes> createState() => _ChangeThemesState();
}

class _ChangeThemesState extends State<ChangeThemes> {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MyProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText("themes"),
        actions: [
          IconButton(
              onPressed: (){
                setState(() {
                  controller.changeTheme();
                });
              }, icon: Icon(controller.darkLight? Icons.dark_mode: Icons.light_mode))
        ],
      ),

      body: const Center(
        child: LocaleText("coming_soon",style: TextStyle(fontSize: 20),),
      ),
    );
  }
}
