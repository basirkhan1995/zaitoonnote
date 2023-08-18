import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';

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
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  late Future<List<Notes>> notes;
  var dropValue = 0;
  var selectedDate = "";
  var selectedCategoryName = "";

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
                        db.createNote(Notes(noteTitle: titleCtrl.text, noteContent: contentCtrl.text,category: selectedCategoryName)).whenComplete(() => Navigator.pop(context));
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
                              asyncItems: (value) => db.getCategoryById(value),
                              itemAsString: (CategoryModel u) =>
                                  Locales.string(context, u.cName.toString()),
                              onChanged: (CategoryModel? data) {
                                setState(() {
                                  selectedCategoryName = data!.cName;
                                });
                              },
                              dropdownButtonProps: DropdownButtonProps(
                                  icon: const Icon(Icons.add, size: 22),
                                  onPressed: () {
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
                                                              db.createCategory(CategoryModel(cName: categoryCtrl.text)).whenComplete(() => Navigator.pop(context));
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
                                  }),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    icon: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Icon(Icons.category),
                                    ),
                                    hintStyle: const TextStyle(fontSize: 13),
                                    hintText: Locales.string(
                                        context, "select_category"),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 4),
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
}
