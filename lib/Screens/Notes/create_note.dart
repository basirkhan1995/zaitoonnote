import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
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
  String categoryType = "note";
  var dropValue = 0;
  var selectedDate = DateTime.now();

  int selectedCategoryId = 9;
  bool selectedColor = false;
  int selectedIndex = 0;
  int? colorValue = zPrimaryColor.value;
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  List colors = [
    noteColor1.value,
    noteColor2.value,
    noteColor3.value,
    noteColor4.value,
    noteColor5.value,
    zPrimaryColor.value,
    Colors.red.shade900.value,
    Colors.green.value,
    Colors.lime.value
  ];

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
                       db.createNote(titleCtrl.text, contentCtrl.text, selectedCategoryId, colorValue!).whenComplete(() => Navigator.of(context).pop(true));
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
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
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
                          height: 35,
                          width: 110,

                          child: DropdownSearch<CategoryModel>(
                            popupProps: const PopupPropsMultiSelection.menu(
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
              Expanded(
                flex: 2,
                child: Padding(
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
              ),

              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        title: LocaleText("colors",style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 15,fontWeight: FontWeight.bold),),
                        leading: const Icon(Icons.color_lens),
                        horizontalTitleGap: 4,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 8,
                        children: List<Widget>.generate(colors.length, (index){
                          selectedColor = selectedIndex == index;
                          return GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedIndex = index;
                                colorValue = colors[selectedIndex];
                              });
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: index == 0 ? zPrimaryColor:index == 1?noteColor2: index ==2 ? noteColor3: index==3 ? noteColor4: index == 4? noteColor5:index == 5?noteColor1:index == 6?Colors.red.shade900:index == 7?Colors.green:index == 8?Colors.lime:zPrimaryColor,
                              child: selectedColor? const Icon(Icons.check,color: Colors.white): const SizedBox(),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
