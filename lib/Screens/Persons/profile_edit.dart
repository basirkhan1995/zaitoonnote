import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:zaitoonnote/Datebase%20Helper/sqlite.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/zfield_underline.dart';
import 'package:zaitoonnote/Screens/Json%20Models/person_model.dart';
import 'package:zaitoonnote/Screens/Settings/Views/accounts.dart';

class EditProfile extends StatefulWidget {
  final PersonModel person;
  const EditProfile({super.key, required this.person});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final formKey = GlobalKey<FormState>();
  var phone = TextEditingController();
  var fullName = TextEditingController();
  var jobTitle = TextEditingController();
  var cardNumber = TextEditingController();
  var cardName = TextEditingController();
  final db = DatabaseHelper();

  @override
  void initState() {
    fullName.text = widget.person.pName!;
    phone.text = widget.person.pPhone!;
    jobTitle.text = widget.person.jobTitle;
    cardNumber.text = widget.person.cardNumber;
    cardName.text = widget.person.accountName;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    String locale = Locales.currentLocale(context).toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person.pName!),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: zPrimaryColor.withOpacity(.09),
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(onPressed: (){
              setState(() {
               db.updateProfileDetails(fullName.text, jobTitle.text, cardNumber.text, cardName.text, phone.text, widget.person.pId).whenComplete(() => Navigator.push(context, MaterialPageRoute(builder: (context)=>const AccountSettings())));
              });
            }, icon: const Icon(Icons.check)),
          )
        ],
      ),

      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                 ListTile(
                  title: LocaleText("profile_update",style: TextStyle(fontFamily: locale == "en"?"Ubuntu":"Dubai",fontSize: 20 ,fontWeight: FontWeight.bold),),
                ),
               const SizedBox(height: 15),
               ZFieldLine(
                 icon: Icons.person,
                 title: "name",
                 controller: fullName,
               ),

                ZFieldLine(
                  icon: Icons.phone,
                  title: "phone",
                  controller: phone,
                ),

                ZFieldLine(
                    icon: Icons.work,
                    title: "job",
                    controller: jobTitle),

                ZFieldLine(
                    icon: Icons.credit_card,
                    title: "card_number",
                    controller: cardNumber,
                ),

                ZFieldLine(
                    icon: Icons.account_circle,
                    title: "account_name",
                    controller: cardName),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
