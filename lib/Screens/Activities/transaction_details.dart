import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicons/unicons.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/z_field.dart';
import 'package:zaitoonnote/Screens/Json%20Models/trn_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';

class TransactionDetails extends StatefulWidget {
  final TransactionModel? data;
  const TransactionDetails({super.key, this.data});

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  final db = DatabaseHelper();
  bool isUpdate = false;
  final amountCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  int selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
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
              color: zPrimaryColor),
          child: IconButton(
            onPressed: () {
              setState(() {
                isUpdate = !isUpdate;
                amountCtrl.text = widget.data!.amount.toString();
                contentCtrl.text = widget.data!.trnDescription.toString();
                updateTransaction();
              });

            },
            icon: const Icon(Icons.edit,color: Colors.white),
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
                    color: Colors.red.shade900),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                     db.deleteTransaction(widget.data?.trnId??0).whenComplete((){
                       Navigator.of(context).pop(true);
                     });
                    });

                  },
                  icon: const Icon(Icons.delete,color: Colors.white),
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
                      color: Colors.grey,fontSize: 18)),
            ),
            Divider(color: Colors.grey.withOpacity(.4),indent: 10,endIndent: 10),
            ListTile(
              subtitle: Text(
                widget.data?.trnDescription ?? "",
                style: TextStyle(
                    fontSize: 18,
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
            Divider(color: Colors.grey.withOpacity(.4),indent: 10,endIndent: 10),
            ListTile(
              subtitle: Text(
                widget.data?.person ?? "",
                style: TextStyle(
                    fontSize: 20,
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
            Divider(color: Colors.grey.withOpacity(.4),indent: 10,endIndent: 10),
            ListTile(
              subtitle: Text(
                Env.currencyFormat(widget.data?.trnId ?? 0, "en_US"),
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            Divider(color: Colors.grey.withOpacity(.4),indent: 10,endIndent: 10),
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
            Divider(color: Colors.grey.withOpacity(.4),indent: 10,endIndent: 10),
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
                ? GestureDetector(
                 onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageDetails(image: widget.data))),
                  child: Hero(
                    tag: 'image',
                    child: Container(
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
                    ),
                  ),
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
                                    db.updateTransaction(contentCtrl.text, int.parse(amountCtrl.text), widget.data!.trnId).whenComplete(() => Navigator.pop(context,'refresh')).then((value) => Navigator.pop(context,'refresh'));
                                  },
                                  icon: const Icon(Icons.check,color: Colors.black87,size: 18)),
                            ),
                          )),

                      ZField(title: "amount",isRequire: true,controller: amountCtrl,icon: Icons.currency_rupee_rounded,),
                      ZField(title: "description",controller: contentCtrl,icon: Icons.info),
                      const SizedBox(height: 20)
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
    });
  }



}


class ImageDetails extends StatefulWidget {
  final TransactionModel? image;
  const ImageDetails({super.key,this.image});

  @override
  State<ImageDetails> createState() => _ImageDetailsState();
}

class _ImageDetailsState extends State<ImageDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InteractiveViewer(
          maxScale: 5.0,
          minScale: 0.01,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Hero(
            tag: 'image',
            child: Container(
              width: MediaQuery.of(context).size.width * .95,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.file(
                          File(widget.image!.trnImage.toString()),
                          fit: BoxFit.cover)
                          .image)),
            ),
          ),
        ),
      ),
    );
  }
}
