import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'dart:io';

import '../../Provider/provider.dart';

class PersonProfile extends StatefulWidget {
  final PersonModel? profileDetails;
  const PersonProfile({super.key, this.profileDetails});

  @override
  State<PersonProfile> createState() => _PersonProfileState();
}

class _PersonProfileState extends State<PersonProfile> {
  
  File? _pImage;
    bool isUpdate = false;
  var phone = TextEditingController();
  var fullName = TextEditingController();
  var jobTitle = TextEditingController();
  var cardNumber = TextEditingController();
  var cardName = TextEditingController();
  var db = DatabaseHelper();

  void update()async{
    int res = await db.updateProfileDetails(fullName.text, jobTitle.text, cardNumber.text, cardName.text, phone.text, DateTime.now().toIso8601String(), widget.profileDetails?.pId);
    if(res >0){
      if (kDebugMode) {
        print("success");
        //Env.showSnackBar("Update","success",context);
      }
    }else{
      if (kDebugMode) {
        print("failed");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Check for phone call support.
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
      });
    });
  }

   @override
  Widget build(BuildContext context) {
     final controller = Provider.of<MyProvider>(context, listen: false);
     final dt = DateTime.parse(widget.profileDetails!.createdAt.toString());
     final updated = DateTime.parse(widget.profileDetails!.updatedAt.toString());

     final updatedWestern = DateFormat('yyyy/MM/dd - HH:mm a').format(updated);
     Jalali updatedPersian = updated.toJalali();
     //Persian Date format
     String updatedPersianDate() {
       final f = updatedPersian.formatter;
       return '${f.yyyy}/${f.mm}/${f.dd}';
     }

     //Created Gregorian Date format
     final createdWesternDate = DateFormat('yyyy/MM/dd - HH:mm a').format(dt);
     Jalali persianDate = dt.toJalali();

     //Persian Date format
     String createdPersianDate() {
       final f = persianDate.formatter;
       return '${f.yyyy}/${f.mm}/${f.dd}';
     }


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
                        const SizedBox(height: 6),
                        const LocaleText(
                          "updated_at",style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(updatedWestern),
                        controller.showHidePersianDate? Text(updatedPersianDate()):const SizedBox(),
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
                  decoration: const InputDecoration(
                    contentPadding:EdgeInsets.symmetric(horizontal: 1),
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
                 setState(() {
                  _makePhoneCall(widget.profileDetails?.pPhone.toString()??"");
                 });
                },
                subtitle: isUpdate? TextFormField(
                  controller: phone,
                  decoration: const InputDecoration(
                    contentPadding:EdgeInsets.symmetric(horizontal: 1),
                    isDense: true,
                  ),
                ):Text(widget.profileDetails?.pPhone??"",style: const TextStyle(fontWeight: FontWeight.bold),),
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
                subtitle: isUpdate? TextFormField(
                  controller: jobTitle,
                  decoration: const InputDecoration(
                    contentPadding:EdgeInsets.symmetric(horizontal: 1),
                    isDense: true,
                  ),
                ):Text(widget.profileDetails?.jobTitle??"",style: const TextStyle(fontWeight: FontWeight.bold),),
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
                subtitle: isUpdate? TextFormField(
                  controller: cardNumber,
                  decoration: const InputDecoration(
                    contentPadding:EdgeInsets.symmetric(horizontal: 1),
                    isDense: true,
                  ),
                ): SelectableText(widget.profileDetails?.cardNumber??"",style: const TextStyle(fontWeight: FontWeight.bold),),
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
                subtitle:isUpdate? TextFormField(
                  controller: cardName,
                  decoration: const InputDecoration(
                    contentPadding:EdgeInsets.symmetric(horizontal: 1),
                    isDense: true,
                  ),
                ): Text(widget.profileDetails?.accountName??"",style: const TextStyle(fontWeight: FontWeight.bold),),
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


            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 35,vertical: 15),
              visualDensity: const VisualDensity(vertical: -4),
              title: Text(createdWesternDate),
              subtitle: Text(createdPersianDate()),
              trailing:const LocaleText("created_at",style: TextStyle(fontSize: 15),),
            ),
            const SizedBox(height: 5),

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
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: zPurpleColor,
                      ),
                      child: isUpdate? TextButton(
                          onPressed: (){
                            setState(() {
                              isUpdate = !isUpdate;
                              // widget.profileDetails?.pName = fullName.text ;
                              // widget.profileDetails?.pPhone = phone.text;
                              // widget.profileDetails?.jobTitle = jobTitle.text;
                              // widget.profileDetails?.cardNumber = cardNumber.text;
                              // widget.profileDetails?.accountName = cardName.text;
                              update();
                            });
                          }, child: const LocaleText("update",style: TextStyle(color: Colors.white),)) : TextButton(
                          onPressed: (){
                               setState((){
                                 isUpdate = !isUpdate;
                                 fullName.text = widget.profileDetails?.pName??"";
                                 phone.text = widget.profileDetails?.pPhone??"";
                                 jobTitle.text = widget.profileDetails?.jobTitle??"";
                                 cardNumber.text = widget.profileDetails?.cardNumber??"";
                                 cardName.text = widget.profileDetails?.accountName??"";
                               });
                          }, child: const LocaleText("settings",style: TextStyle(color: Colors.white),)),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future <void> getImage(ImageSource imageSource)async{
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile == null)return;
    setState((){
      _pImage = File(pickedFile.path);
      if (kDebugMode) {
        print(_pImage);
      }
    });
  }


}
