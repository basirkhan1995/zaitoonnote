import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/z_field.dart';
import 'package:zaitoonnote/Screens/Json%20Models/trn_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/custom_drop_down.dart';
import '../../Methods/env.dart';
import '../../Provider/provider.dart';

class TransactionDetails extends StatefulWidget {
  final TransactionModel? data;
  const TransactionDetails({super.key, this.data});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  final db = DatabaseHelper();

  File? _trnImage;
  bool isUpdate = false;

  final amountCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  int selectedIndex = 0;
  int selectedCategory = 0;

  int selectedValue = 0;

  List category = [
    "paid",
    "received",
    "check",
    "rent",
    "power",
  ];

  List categoryId = <int> [
    2,
    3,
    4,
    5,
    6,
  ];
   
  void transactionUpdate(){
   
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context, listen: false);
    String currentLocale = Locales.currentLocale(context).toString();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(widget.data!.person),
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Container(
                height: 45,
                width: 45,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: zPrimaryColor.withOpacity(.1)),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                     db.deleteTransaction(widget.data?.trnId??0).whenComplete((){
                       Navigator.pop(context);
                     });
                    });

                  },
                  icon: const Icon(Icons.delete,color: Colors.red),
                ),
              )),

          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Container(
                height: 45,
                width: 45,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: zPrimaryColor.withOpacity(.1)),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isUpdate = !isUpdate;
                      amountCtrl.text = widget.data!.amount.toString();
                      contentCtrl.text = widget.data!.trnDescription.toString();
                      updateTransaction();
                    });

                  },
                  icon: const Icon(Icons.edit),
                ),
              )),

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              subtitle: Text(
                Env.currencyFormat(widget.data?.amount ?? 0, "en_US"),
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              title: Row(
                children: [
                  LocaleText(
                    "amount",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                    decoration: BoxDecoration(
                        color: widget.data!.trnCategory == "received"
                            ? Colors.lightGreen
                            : Colors.red.shade700,
                        borderRadius: BorderRadius.circular(4)),
                    child: Icon(
                      widget.data!.trnCategory == "received"
                          ? UniconsLine.arrow_down_left
                          : UniconsLine.arrow_up_right,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
              trailing: LocaleText(widget.data?.trnCategory ?? "",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                      color: Colors.grey)),
            ),
            ListTile(
              subtitle: Text(
                widget.data?.person ?? "",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai"),
              ),
              title: LocaleText(
                "trn_person",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              title: LocaleText(
                "created_at",
                style: TextStyle(
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              subtitle: Text(
                currentLocale == "en"
                    ? Env.gregorianDateTimeForm(
                        widget.data!.createdAt.toString())
                    : Env.persianDateTimeFormat(
                        DateTime.parse(widget.data!.createdAt.toString())),
                style: TextStyle(
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              subtitle: Text(
                Env.currencyFormat(widget.data?.trnId ?? 0, "en_US"),
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              title: LocaleText(
                "trn_id",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              subtitle: Text(
                widget.data?.trnDescription ?? "",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai"),
              ),
              title: LocaleText(
                "description",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: LocaleText(
                "trn_image",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                    fontWeight: FontWeight.bold),
              ),
            ),

            widget.data!.trnImage!.isNotEmpty
                ? Container(
                  width: MediaQuery.of(context).size.width * .95,
                  height: 250,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.file(
                                  File(widget.data!.trnImage.toString()),
                                  fit: BoxFit.cover)
                              .image)),
                )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

   updateTransaction() {
    String currentLocale = Locales.currentLocale(context).toString();

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        height: 5,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 0, left: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                            title: LocaleText(
                              "update_transaction",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: currentLocale == "en" ? "Ubuntu" : "Dubai",
                                  color: Colors.grey),
                            ),
                            leading: const Icon(UniconsLine.transaction),
                            trailing: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(.4),
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                  onPressed: (){
                                    db.updateTransaction(contentCtrl.text, int.parse(amountCtrl.text), widget.data!.trnId).whenComplete(() => Navigator.pop(context));
                                     print(selectedValue.toString());
                                  },
                                  icon: const Icon(Icons.check,color: Colors.black87,size: 18)),
                            ),
                          )),

                      ZField(title: "amount",isRequire: true,controller: amountCtrl,icon: Icons.currency_rupee_rounded,),
                      ZField(title: "description",controller: contentCtrl,icon: Icons.info),
                  //
                  //     const ListTile(title: Text("Category"),visualDensity: VisualDensity(vertical: -4)),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8),
                  //       child: Row(
                  //         children: [
                  //
                  //           Expanded(
                  //             flex: 2,
                  //             child: Container(
                  //               padding: const EdgeInsets.symmetric(horizontal: 15),
                  //               height: 50,
                  //               decoration: BoxDecoration(
                  //                   border: Border.all(
                  //                       color: zPrimaryColor
                  //                   ),
                  //                   borderRadius: BorderRadius.circular(8)),
                  //               child: CustomDropDown(
                  //                 items: const [
                  //                   CustomDropdownMenuItem(
                  //                       value: 2,
                  //                       child: LocaleText("paid")
                  //                   ),
                  //                   CustomDropdownMenuItem(
                  //                     value: 3,
                  //                     child: LocaleText("received"),
                  //                   ),
                  //                   CustomDropdownMenuItem(
                  //                     value: 4,
                  //                     child: LocaleText("check"),
                  //                   ),
                  //
                  //                 ],
                  //                 hintText: Locales.string(context, "select_category"),
                  //                 borderRadius: 5,
                  //                 onChanged: (val) {
                  //                   setState(() {
                  //                     selectedValue = val;
                  //                   });
                  //                 },
                  //               ),
                  //             ),
                  //           ),
                  //
                  //           Expanded(
                  //             child: Container(
                  //               margin: const EdgeInsets.symmetric(horizontal: 6),
                  //               decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius.circular(8),
                  //                   color: zPrimaryColor.withOpacity(.2)
                  //               ),
                  //               child: IconButton(onPressed: (){
                  //                 getImage(ImageSource.gallery);
                  //               }, icon: const Icon(Icons.camera_alt)),
                  //             ),
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //
                  //     widget.data!.trnImage!.isNotEmpty
                  //         ? Container(
                  //       width: MediaQuery.of(context).size.width * .95,
                  //       height: 250,
                  //       decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(10),
                  //           image: DecorationImage(
                  //               fit: BoxFit.cover,
                  //               image: Image.file(
                  //                   File(widget.data!.trnImage.toString()),
                  //                   fit: BoxFit.cover)
                  //                   .image)),
                  //     ): _trnImage != null ? Container(
                  //   width: MediaQuery.of(context).size.width * .95,
                  //   height: 250,
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(10),
                  //       image: DecorationImage(
                  //           fit: BoxFit.cover,
                  //           image: Image.file(
                  //               File(_trnImage.toString()),
                  //               fit: BoxFit.cover)
                  //               .image)),
                  // ):const SizedBox()
                      SizedBox(height: 20)
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future <void> getImage(ImageSource imageSource)async{
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile == null)return;
    setState((){
      _trnImage = File(pickedFile.path);
      print(_trnImage);
    });
  }
}
