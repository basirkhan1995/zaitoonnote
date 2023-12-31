import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Screens/Activities/all_activities.dart';
import 'package:zaitoonnote/Screens/Json%20Models/users.dart';
import 'package:zaitoonnote/Screens/Notes/all_notes.dart';
import 'package:zaitoonnote/Screens/Settings/settings.dart';
import '../dashboard.dart';


class BottomNavBar extends StatefulWidget {
  final UsersModel? users;
  const BottomNavBar({Key? key,this.users}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}


class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  List<IconData> icons =[
     Icons.bar_chart_rounded,
    Icons.event_note,
    Icons.event,
    Icons.settings,
  ];
  List titles = [
    "dashboard",
    "notes",
    "activity",
    "settings",
  ];

 late List<Widget> screens;

  @override
  void initState() {
    screens = <Widget>[
      Dashboard(usr: widget.users),
      const AllNotes(),
      const AllActivities(),
      const SettingsPage(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
        decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(.1),
            borderRadius: BorderRadius.circular(10)
        ),
        height: 65,
        child: ListView.builder(
            itemCount: 4,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: size.width *.015),
            itemBuilder: (context,index)=>InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: (){
                setState(() {
                  currentIndex = index;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 5),
                  Icon(icons[index],size: index == currentIndex? 26:24,color: index == currentIndex? Colors.deepPurple:Colors.black54),
                  LocaleText(titles[index],style: TextStyle(color: index == currentIndex? Colors.deepPurple:Colors.black54,fontSize: 12),),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    width: size.width *.140,
                    height: index == currentIndex? 5:0,
                    margin: EdgeInsets.only(
                        right: size.width* .0422,
                        left: size.width* .0422,
                        top: index == currentIndex? size.width * .014:0),
                    decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20)
                        )
                    ),
                  )
                ],
              ),
            )),
      ),
      body: screens[currentIndex],
    );
  }
}
