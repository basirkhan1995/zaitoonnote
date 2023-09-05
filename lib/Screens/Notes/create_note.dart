import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import 'dart:io';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../../Methods/textfield.dart';
import '../Json Models/note_model.dart';

class CreateNote extends StatefulWidget {
  const CreateNote({super.key});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final formKey = GlobalKey<FormState>();
  final cFormKey = GlobalKey <FormState>();
  final db = DatabaseHelper();

  late Future<List<Notes>> notes;
  File? _noteImage;
  var dropValue = 0;
  var selectedDate = DateTime.now();

  int selectedCategoryId = 0;
  String categoryType = "note";

  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String currentLocale = Locales.currentLocale(context).toString();
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText("create_note"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 45,
              width: 70,
              decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8)),
              child: TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                       db.createNote(titleCtrl.text, contentCtrl.text, selectedCategoryId).whenComplete(() => Navigator.pop(context));
                      });
                    }
                  },
                  child: const Icon(Icons.check,size: 23)),
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: InkWell(
                        onTap: ()=>setState(() {
                          showGregorianPicker();
                        }),
                        child: Text(
                          Env.gregorianDateTimeForm(selectedDate.toString()),
                          style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
                        ),
                      ),
                      subtitle: InkWell(
                          onTap: ()=>
                              setState(() {
                                showPersianPicker(); }),
                          child: Text(
                            Env.persianDateTimeFormat(selectedDate),style: TextStyle(fontSize: 15,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: 50,
                          width: 110,

                          child: DropdownSearch<CategoryModel>(
                            popupProps: PopupPropsMultiSelection.menu(
                              fit: FlexFit.loose,

                            ),

                            asyncItems: (value) => db.getCategoryByType("note"),
                            itemAsString: (CategoryModel u) =>
                                Locales.string(context, u.cName.toString()),
                            onChanged: (CategoryModel? data) {
                              setState(() {
                                selectedCategoryId = data?.cId??2;
                              });
                            },

                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                  hintStyle: TextStyle(fontSize: 14,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontWeight: FontWeight.bold),
                                  hintText: Locales.string(
                                      context, "category"),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 0),
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return Locales.string(context, "title_required");
                    }else if(titleCtrl.text.length >20){
                      return Locales.string(context, "title_minimum_char");
                    }
                    return null;
                  },
                  controller: titleCtrl,
                  style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 20,fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: Locales.string(context, "title"),
                    border: InputBorder.none,
                    helperStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 20,fontWeight: FontWeight.bold),
                    labelStyle:TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 20,fontWeight: FontWeight.bold) ,
                    hintStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 20,fontWeight: FontWeight.bold),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 0),
                child: TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return Locales.string(context, "content_required");
                    }
                    return null;
                  },
                  style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 17,),
                  controller: contentCtrl,
                  decoration: InputDecoration(
                    hintText: Locales.string(context, "content",),
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 17),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addCategory(){
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SizedBox(
              height: 200,
              width: double.maxFinite,
              child: Form(
                key: cFormKey,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10),
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius:
                          BorderRadius
                              .circular(8)),
                    ),
                    UnderlineInputField(
                      validator: (value){
                        if(value.isEmpty){
                          return Locales.string(context, "category_required");
                        }
                        return null;
                      },
                      hint: "category_name",
                      controller: categoryCtrl,
                    ),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child:
                            const LocaleText("cancel")),
                        TextButton(
                            onPressed: () {
                              if(cFormKey.currentState!.validate()){
                                db.createCategory(CategoryModel(cName: categoryCtrl.text,categoryType: categoryType)).whenComplete(() => Navigator.pop(context));
                              }
                            },
                            child:
                            const LocaleText(
                                "create")),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future <void> getImage(ImageSource imageSource)async{
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile == null)return;
    setState((){
      _noteImage = File(pickedFile.path);
      print(_noteImage);
    });
  }

  showGregorianPicker()async{

    var picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000), initialDate: DateTime.now(),
    );

    if(picked != null){
      setState(() {
        selectedDate = picked;
      });
    }
    return picked;
  }

  showPersianPicker()async{
    var picked = await showPersianDatePicker(
      context: context,
      initialEntryMode: PDatePickerEntryMode.calendar,
      firstDate: Jalali(1350, 8),
      lastDate: Jalali(1500, 9), initialDate: DateTime.now().toJalali(),
    );
    if(picked != null){
      setState(() {
        selectedDate = picked.toDateTime();
      });
    }
    return picked;
  }

}
