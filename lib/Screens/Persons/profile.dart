import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'dart:io';

class PersonProfile extends StatefulWidget {
  final PersonModel? profileDetails;
  const PersonProfile({super.key, this.profileDetails});

  @override
  State<PersonProfile> createState() => _PersonProfileState();
}

class _PersonProfileState extends State<PersonProfile> {
  
  File? _pImage;
    bool isUpdate = false;
  final phone = TextEditingController();
  final fullName = TextEditingController();
  final jobTitle = TextEditingController();
  final cardNumber = TextEditingController();
  final cardName = TextEditingController();
   @override
  Widget build(BuildContext context) {
    final db = DatabaseHelper();
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
          children: [
              Row(
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 62,
                              backgroundColor: zPurpleColor,
                              child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: widget.profileDetails!.pImage!.isNotEmpty
                                      ? Image.file(
                                          File(widget.profileDetails!.pImage.toString()),
                                          fit: BoxFit.cover,
                                        ).image
                                      : const AssetImage("assets/Photos/no_user.jpg")),
                            ),
                          ),
                          Positioned(
                            top: 95,
                              left: 90,
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.deepPurple
                                ),
                                child: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        getImage(ImageSource.gallery).whenComplete(() {
                                          if(_pImage == null) return;
                                          db.updateProfileImage(_pImage?.path??widget.profileDetails?.pImage??"", widget.profileDetails?.pId??0);
                                        });
                                      });


                                    }, icon: const Icon(Icons.camera_alt,color: Colors.white,size: 18,)),
                              )),
                        ],
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
                          widget.profileDetails?.pName ?? "",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const LocaleText("account_no",style: TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: zPurpleColor
                              ),
                              child: Text(
                                widget.profileDetails?.pId.toString() ?? "",
                                style: const TextStyle(fontSize: 16,color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.profileDetails?.pPhone ?? "",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            //Body
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                horizontalTitleGap: 15,
                subtitle: isUpdate? TextFormField(
                  controller: fullName,
                  decoration: InputDecoration(
                    contentPadding:const EdgeInsets.symmetric(horizontal: 1),
                    isDense: true,

                  ),
                ) : Text(widget.profileDetails?.pName??"",style: const TextStyle(fontWeight: FontWeight.bold),),
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
                subtitle: Text(widget.profileDetails?.pPhone??"",style: const TextStyle(fontWeight: FontWeight.bold),),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                horizontalTitleGap: 15,
                onTap: () {

                },
                subtitle: Text(widget.profileDetails?.jobTitle??"",style: const TextStyle(fontWeight: FontWeight.bold),),
                leading: Container(
                  margin: const EdgeInsets.all(0),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.deepPurple.withOpacity(.09)),
                  child: const Icon(
                    Icons.work,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                ),
                title: const LocaleText(
                  "job",
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
                subtitle: SelectableText(widget.profileDetails?.cardNumber??"",style: const TextStyle(fontWeight: FontWeight.bold),),
                leading: Container(
                  margin: const EdgeInsets.all(0),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.deepPurple.withOpacity(.09)),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                ),
                title: const LocaleText(
                  "card_number",
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
                subtitle: Text(widget.profileDetails?.accountName??"",style: const TextStyle(fontWeight: FontWeight.bold),),
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
                  "account_name",
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


            const SizedBox(height: 20),
            
            //End
            SizedBox(

              width: MediaQuery.of(context).size.width *.85,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: zPurpleColor,
                      ),
                      child: TextButton(
                          onPressed: (){
                               setState(() {
                                 isUpdate = !isUpdate;
                               });
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
      ),
    );
  }

  Future <void> getImage(ImageSource imageSource)async{
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile == null)return;
    setState((){
      _pImage = File(pickedFile.path);
      print(_pImage);
    });
  }
}
