import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../Json Models/category_model.dart';
import '../Json Models/note_model.dart';

class NoteDetails extends StatefulWidget {
  final Notes? details;
  const NoteDetails({super.key, this.details});

  @override
  State<NoteDetails> createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  final db = DatabaseHelper();
  bool isUpdate = false;
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  var dropValue = 0;
  DateTime? selectedDate;
  int? selectedCategoryId;
  late DatabaseHelper handler;
  late Future<List<Notes>> notes;
  String categoryType = "note";



  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    notes = handler.getNotes();
    handler.initDB().whenComplete(() async {
      setState(() {
        notes = getList();
      });
    });
  }

  //Method to get data from database
  Future<List<Notes>> getList() async {
    return await handler.getNotes();
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      notes = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentLocale = Locales.currentLocale(context).toString();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: [

          isUpdate ? Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: zPrimaryColor
            ),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    isUpdate = !isUpdate;
                    db.updateNote(
                         titleCtrl.text,
                         contentCtrl.text,
                         selectedCategoryId.toString(),
                         selectedDate.toString(),
                         widget.details!.noteId).whenComplete(() => Navigator.pop(context,'refresh'));
                  });
                },
                icon: const Icon(
                  Icons.check,color: Colors.white,
                  size: 18,
                )),
          )
              : Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: zPrimaryColor
            ),
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        isUpdate = !isUpdate;
                        titleCtrl.text = widget.details!.noteTitle;
                        contentCtrl.text = widget.details!.noteContent;
                        selectedCategoryId = widget.details!.cId;
                        selectedDate = DateTime.parse(widget.details!.createdAt.toString());
                        _onRefresh();
                      });
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    )),
              ),

          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.red.shade900
                ),
                child: IconButton(onPressed: ()=>db.deleteNote(widget.details!.noteId.toString()).whenComplete(() => Navigator.of(context).pop(true)), icon:const Icon(Icons.delete,color: Colors.white,),)),
          ),
        ],
        title: Text(widget.details!.noteTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding:const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2),
              child: LocaleText(
                "recent_update",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",color: Colors.grey),
              ),
            ),
            ListTile(
              title: InkWell(
                onTap: ()=>setState(() {
                  showGregorianPicker();
                }),
                child: Text(
                   Env.gregorianDateTimeForm(selectedDate == null? widget.details!.createdAt.toString() : selectedDate!.toIso8601String()),
                  style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
                ),
              ),
              subtitle: InkWell(
                  onTap: ()=>
                      setState(() {
                        showPersianPicker(); }),
                  child: Text(
                    Env.persianDateTimeFormat(DateTime.parse(selectedDate == null? widget.details!.createdAt.toString():selectedDate!.toIso8601String())),style: TextStyle(fontSize: 15,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),)),

             trailing: isUpdate? Container(
               padding: const EdgeInsets.symmetric(horizontal: 6),
               margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 11),
               height: 60,
               width: 100,

               decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
               child: DropdownSearch<CategoryModel>(
                 popupProps: const PopupPropsMultiSelection.menu(
                   fit: FlexFit.loose,
                 ),

                 asyncItems: (value) => db.getCategoryByType("note"),
                 itemAsString: (CategoryModel u) => Locales.string(context, u.cName.toString()),
                 onChanged: (CategoryModel? data) {
                   setState(() {
                     selectedCategoryId = data?.cId??2;
                   });
                 },

                 dropdownDecoratorProps: DropDownDecoratorProps(
                   dropdownSearchDecoration: InputDecoration(

                       hintStyle: TextStyle(fontSize: 16,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontWeight: FontWeight.bold),
                       hintText: Locales.string(context, "category"),
                       contentPadding: const EdgeInsets.symmetric(
                           horizontal: 0, vertical: 0),
                       border: InputBorder.none),
                 ),
               ),
             ):Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                 decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                   color: zPrimaryColor,
                 ),
                 child: LocaleText(widget.details!.category.toString(),style: TextStyle(color: Colors.white,fontSize: 15,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),)),
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              visualDensity: const VisualDensity(vertical: -4),
              dense: true,
              title: LocaleText(
                "title",
                style: TextStyle(color: Colors.grey,fontSize: 18, fontWeight: FontWeight.bold,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
              ),
              subtitle: isUpdate
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 0),
                child: TextFormField(
                  validator: (value){
                    if(value!.isEmpty){
                      return Locales.string(context, "title_required");
                    }
                    return null;
                  },
                  style: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 17,),
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: Locales.string(context, "title",),
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 17),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              )
                  : Text(
                      widget.details!.noteTitle,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold),
                    ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: ListTile(
                  visualDensity: const VisualDensity(vertical: -4),
                  dense: true,
                  title: LocaleText(
                    "content",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"
                    ),
                  ),
                  subtitle: isUpdate
                      ? Padding(
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
                        hintText: Locales.string(context, "content"),
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",fontSize: 17),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  )
                      : Text(
                          widget.details!.noteContent,
                          style: TextStyle(
                              fontSize: 15, color: Colors.black38,fontFamily: currentLocale == "en"?"Ubuntu":"Dubai"),
                        ),
                ),
              ),
            ),
          ],
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
