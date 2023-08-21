import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import 'dart:io';
import '../../Datebase Helper/sqlite.dart';
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
  var selectedDate = "";

  int selectedCategoryId = 0;
  String categoryType = "note";

  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();

    //Gregorian Date format
    final gregorianDate =
        DateFormat('yyyy-MM-dd (HH:mm a)').format(selectedDate);
    Jalali persianDate = selectedDate.toJalali();

    //Persian Date format
    String shamsiDate() {
      final f = persianDate.formatter;
      return '${f.yyyy}/${f.mm}/${f.dd}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const LocaleText("create_note"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 45,
              width: 90,
              decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8)),
              child: TextButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                       db.createNote(titleCtrl.text, contentCtrl.text, selectedCategoryId, "imageval").whenComplete(() => Navigator.pop(context));
                      });
                    }
                  },
                  child: const LocaleText(
                    "create",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  )),
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
                      onTap: () {
                        setState(() {
                          final DateTime dateTime = showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(3000)) as DateTime;
                          setState(() {
                            selectedDate = dateTime;
                          });
                        });
                      },
                      title: Text(
                        gregorianDate,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(shamsiDate()),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 40,
                            width: 160,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(.1),
                                borderRadius: BorderRadius.circular(10)),
                            child: DropdownSearch<CategoryModel>(
                              popupProps: PopupPropsMultiSelection.modalBottomSheet(
                                fit: FlexFit.loose,
                                title: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      height: 5,
                                      width: 60,
                                      decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius:
                                          BorderRadius
                                              .circular(15)),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 0, left: 10),
                                        child: ListTile(
                                          title: const LocaleText("select_category",style: TextStyle(fontSize: 18),),
                                          leading: const Icon(Icons.category),
                                          trailing: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius: BorderRadius.circular(50)
                                            ),
                                            child: IconButton(
                                                onPressed: ()=> addCategory(),
                                                icon: const Icon(Icons.add,color: Colors.white,size: 18)),
                                          ),
                                        )
                                    ),
                                  ],
                                ),

                              ),

                              asyncItems: (value) => db.getCategoryByType("note"),
                              itemAsString: (CategoryModel u) =>
                                  Locales.string(context, u.cName.toString()),
                              onChanged: (CategoryModel? data) {
                                setState(() {
                                  selectedCategoryId = data?.cId??2;
                                });
                              },
                              dropdownButtonProps: DropdownButtonProps(
                                  icon: const Icon(Icons.arrow_drop_down_circle_outlined, size: 22),
                                  onPressed: () {

                                  }),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    hintStyle: const TextStyle(fontSize: 13),
                                    hintText: Locales.string(
                                        context, "select_category"),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              UnderlineInputField(
                validator: (value) {
                  if (value.isEmpty) {
                    return Locales.string(context, "title_required");
                  }else if(titleCtrl.text.length >10){
                    return "title_minimum_char";
                  }
                  return null;
                },
                hint: "title",
                controller: titleCtrl,
              ),
              IntrinsicHeight(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 250,
                    maxHeight: 500,
                  ),
                  child: UnderlineInputField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return Locales.string(context, "content_required");
                      }
                      return null;
                    },
                    hint: "content",
                    controller: contentCtrl,
                    maxChar: 500,
                    max: null,
                    expand: true,
                  ),
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

}
