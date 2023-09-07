import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Persons/profile_edit.dart';
import 'package:zaitoonnote/Screens/Settings/Views/accounts.dart';
import 'dart:io';
import '../../Methods/env.dart';


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

  void update() async {
    int res = await db.updateProfileDetails(fullName.text, jobTitle.text,
        cardNumber.text, cardName.text, phone.text, widget.profileDetails?.pId);
    if (res > 0) {
      if (kDebugMode) {
        //Env.showSnackBar("Update","success",context);
      }
    } else {
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
    String locale = Locales.currentLocale(context).toString();
    return Scaffold(
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [

           Column(
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
                               radius: 58,
                               backgroundColor: zPrimaryColor,
                               child: GestureDetector(
                                 onTap: (){
                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileImageDetails(image: widget.profileDetails)));
                                 },
                                 child: Hero(
                                   tag: 'image',
                                   child: CircleAvatar(
                                       radius: 56,
                                       backgroundImage:
                                       widget.profileDetails!.pImage!.isNotEmpty
                                           ? Image.file(
                                         File(widget.profileDetails!.pImage
                                             .toString()),
                                         fit: BoxFit.cover,
                                       ).image
                                           : const AssetImage(
                                           "assets/Photos/no_user.jpg")),
                                 ),
                               ),
                             ),
                           ),
                           Positioned(
                               top: 90,
                               left: 85,
                               child: Container(
                                 height: 35,
                                 width: 35,
                                 decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(50),
                                     color: Colors.deepPurple),
                                 child: IconButton(
                                     onPressed: () {
                                       setState(() {
                                         getImage(ImageSource.gallery).whenComplete(() {
                                           if (_pImage == null) return;
                                           db.updateProfileImage(
                                               _pImage?.path ?? widget.profileDetails?.pImage ?? "", widget.profileDetails?.pId ?? 0);
                                         }).then((value) => Navigator.push(context, MaterialPageRoute(builder: (context)=> const AccountSettings())));
                                       });
                                     },
                                     icon: const Icon(
                                       Icons.camera_alt,
                                       color: Colors.white,
                                       size: 18,
                                     )),
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
                           style: TextStyle(
                               fontSize: largeSize, fontWeight: FontWeight.bold,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                         ),
                         Row(
                           children: [
                              LocaleText(
                               "account_no",
                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: smallSize,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                             ),
                             const SizedBox(width: 6),
                             Container(
                               padding: const EdgeInsets.symmetric(
                                   horizontal: 6, vertical: 0),
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(4),
                                   color: zPrimaryColor),
                               child: Text(
                                 widget.profileDetails?.pId.toString() ?? "",
                                 style: const TextStyle(
                                     fontSize: smallSize, color: Colors.white),
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 6),
                          LocaleText(
                           "updated_at",
                           style: TextStyle(fontWeight: FontWeight.bold,fontSize: smallSize,color: Colors.grey,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                         ),
                         Text(locale != "en"
                             ? Env.persianDateTimeFormat(DateTime.parse(
                             widget.profileDetails!.updatedAt.toString()))
                             : Env.gregorianDateTimeForm(
                             widget.profileDetails!.updatedAt.toString()),style: TextStyle(fontSize: mediumSize,fontFamily: locale == "en"?"Ubuntu":"Dubai"),),
                       ],
                     ),
                   ),
                 ],
               ),
             ],
           ),

           Column(
             children: [
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                   horizontalTitleGap: 15,
                   subtitle:Text(
                     widget.profileDetails?.pName ?? "",
                     style: TextStyle(fontWeight: FontWeight.bold,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
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
                   title: LocaleText(
                     "name",
                     style: TextStyle(fontSize: 14,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
                   trailing: Container(
                       height: 25,
                       width: 25,
                       decoration: BoxDecoration(
                           color: Colors.deepPurple.withOpacity(.09),
                           borderRadius: BorderRadius.circular(50)),
                       child: const Icon(Icons.arrow_forward_ios_rounded,
                           size: 12)),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                   horizontalTitleGap: 15,
                   onTap: () {
                     setState(() {
                       _makePhoneCall(
                           widget.profileDetails?.pPhone.toString() ?? "");
                     });
                   },
                   subtitle: Text(
                     widget.profileDetails?.pPhone ?? "",
                     style: TextStyle(fontWeight: FontWeight.bold,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
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
                   title: LocaleText(
                     "phone",
                     style: TextStyle(fontSize: 14,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
                   trailing: Container(
                       height: 25,
                       width: 25,
                       decoration: BoxDecoration(
                           color: Colors.deepPurple.withOpacity(.09),
                           borderRadius: BorderRadius.circular(50)),
                       child: const Icon(Icons.arrow_forward_ios_rounded,
                           size: 12)),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                   horizontalTitleGap: 15,
                   onTap: () {},
                   subtitle: Text(
                     widget.profileDetails?.jobTitle ?? "",
                     style: TextStyle(fontWeight: FontWeight.bold,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
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
                   title: LocaleText(
                     "job",
                     style: TextStyle(fontSize: normalSize,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
                   trailing: Container(
                       height: 25,
                       width: 25,
                       decoration: BoxDecoration(
                           color: Colors.deepPurple.withOpacity(.09),
                           borderRadius: BorderRadius.circular(50)),
                       child: const Icon(Icons.arrow_forward_ios_rounded,
                           size: 12)),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                   horizontalTitleGap: 15,
                   onTap: () {},
                   subtitle: SelectableText(
                     widget.profileDetails?.cardNumber ?? "",
                     style: TextStyle(fontWeight: FontWeight.bold, fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
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
                   title: LocaleText(
                     "card_number",
                     style: TextStyle(fontSize: 14,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
                   trailing: Container(
                       height: 25,
                       width: 25,
                       decoration: BoxDecoration(
                           color: Colors.deepPurple.withOpacity(.09),
                           borderRadius: BorderRadius.circular(50)),
                       child: const Icon(Icons.arrow_forward_ios_rounded,
                           size: 12)),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
                 child: ListTile(
                   contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                   horizontalTitleGap: 15,
                   onTap: () {},
                   subtitle: Text(
                     widget.profileDetails?.accountName ?? "",
                     style: const TextStyle(fontWeight: FontWeight.bold),
                   ),
                   leading: Container(
                     margin: const EdgeInsets.all(0),
                     height: 50,
                     width: 50,
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(50),
                         color: Colors.deepPurple.withOpacity(.09)),
                     child: const Icon(
                       Icons.account_circle,
                       color: Colors.deepPurple,
                       size: 24,
                     ),
                   ),
                   title: LocaleText(
                     "account_name",
                     style: TextStyle(fontSize: 14,fontFamily: locale == "en"?"Ubuntu":"Dubai"),
                   ),
                   trailing: Container(
                       height: 25,
                       width: 25,
                       decoration: BoxDecoration(
                           color: Colors.deepPurple.withOpacity(.09),
                           borderRadius: BorderRadius.circular(50)),
                       child: const Icon(Icons.arrow_forward_ios_rounded,
                           size: 12)),
                 ),
               ),
             ],
           ),

           Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ListTile(
                    title: LocaleText("created_at",style: TextStyle(fontFamily: locale == "en" ? "Ubuntu":"Dubai" ),),
                    subtitle: Text(Env.gregorianDateTimeForm(widget.profileDetails!.createdAt.toString()),style: TextStyle(fontFamily: locale == "en" ? "Ubuntu":"Dubai" )),
                    trailing: Wrap(
                      spacing: 10,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                          color: zPrimaryColor,
                          borderRadius: BorderRadius.circular(50)
                        ),
                          width: 40,
                          height: 40,
                            child: IconButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(person: widget.profileDetails!))).then((value) {
                              Env.goto(const AccountSettings(), context);
                            }), icon: const Icon(Icons.edit,color: Colors.white)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.red.shade900,
                              borderRadius: BorderRadius.circular(50)
                          ),
                          width: 40,
                          height: 40,
                          child: IconButton(onPressed: ()=>db.deletePerson(widget.profileDetails!.pId.toString(),context).whenComplete(() => Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const AccountSettings())) ), icon: const Icon(Icons.delete,color: Colors.white,)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> getImage(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile == null) return;
    setState(() {
      _pImage = File(pickedFile.path);
      if (kDebugMode) {
        print(_pImage);
      }
    });
  }


}


class ProfileImageDetails extends StatefulWidget {
  final PersonModel? image;
  const ProfileImageDetails({super.key,this.image});

  @override
  State<ProfileImageDetails> createState() => _ProfileImageDetailsState();
}

class _ProfileImageDetailsState extends State<ProfileImageDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'image',
          child: InteractiveViewer(
            maxScale: 5.0,
            minScale: 0.01,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .5,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: widget.image!.pImage!.isNotEmpty
                          ? Image.file(
                        File(widget.image!.pImage
                            .toString()),
                        fit: BoxFit.contain,
                      ).image
                          : const AssetImage(
                          "assets/Photos/no_user.jpg")
                          )),
            ),
          ),
        ),
      ),
    );
  }
}