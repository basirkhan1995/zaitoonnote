import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'dart:io';

class PersonProfile extends StatelessWidget {
  final PersonModel? profileDetails;
  const PersonProfile({super.key, this.profileDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
        children: [
            Row(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 62,
                        backgroundColor: zPurple,
                        child: CircleAvatar(
                            radius: 60,
                            backgroundImage: profileDetails!.pImage!.isNotEmpty
                                ? Image.file(
                                    File(profileDetails!.pImage.toString()),
                                    fit: BoxFit.cover,
                                  ).image
                                : const AssetImage("assets/Photos/no_user.jpg")),
                      ),
                    ),
                  ],
                ),

                //Header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileDetails?.pName ?? "",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const LocaleText("account_no",style: TextStyle(fontWeight: FontWeight.bold),),
                          const SizedBox(width: 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6,vertical: 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: zPurple
                            ),
                            child: Text(
                              profileDetails?.pId.toString() ?? "",
                              style: const TextStyle(fontSize: 16,color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        profileDetails?.pPhone ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          //Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              horizontalTitleGap: 15,
              onTap: () {

              },
              subtitle: Text(profileDetails?.pName??"",style: const TextStyle(fontWeight: FontWeight.bold),),
              leading: Container(
                margin: const EdgeInsets.all(0),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.deepPurple.withOpacity(.09)),
                child: const Icon(
                  Icons.person,
                  color: Colors.deepPurple,
                  size: 24,
                ),
              ),
              title: const LocaleText(
                "name",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              horizontalTitleGap: 15,
              onTap: () {

              },
              subtitle: Text(profileDetails?.pId.toString()??"",style: const TextStyle(fontWeight: FontWeight.bold),),
              leading: Container(
                margin: const EdgeInsets.all(0),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.deepPurple.withOpacity(.09)),
                child: const Icon(
                  Icons.account_box,
                  color: Colors.deepPurple,
                  size: 24,
                ),
              ),
              title: const LocaleText(
                "account_no",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              horizontalTitleGap: 15,
              onTap: () {

              },
              subtitle: Text(profileDetails?.pPhone??"",style: const TextStyle(fontWeight: FontWeight.bold),),
              leading: Container(
                margin: const EdgeInsets.all(0),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.deepPurple.withOpacity(.09)),
                child: const Icon(
                  Icons.phone,
                  color: Colors.deepPurple,
                  size: 24,
                ),
              ),
              title: const LocaleText(
                "phone",
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


          SizedBox(height: 20),
          //End
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: zPurple.withOpacity(.09),
              borderRadius: BorderRadius.circular(8)
            ),
            width: MediaQuery.of(context).size.width *.9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: zPurple,
                    ),
                    child: TextButton(
                        onPressed: (){

                        }, child: const LocaleText("settings",style: TextStyle(color: Colors.white),)),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red.shade900,
                    ),
                    child: TextButton(
                        onPressed: (){

                        }, child: const LocaleText("delete",style: TextStyle(color: Colors.white),)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
          )),
    );
  }
}
