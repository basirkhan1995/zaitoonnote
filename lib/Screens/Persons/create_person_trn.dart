
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Methods/z_field.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../Json Models/category_model.dart';
import '../Json Models/person_model.dart';
import 'dart:io';

class CreatePersonTransaction extends StatefulWidget {
  final PersonModel? person;
  const CreatePersonTransaction({super.key, this.person});

  @override
  State<CreatePersonTransaction> createState() => _CreatePersonTransactionState();
}

class _CreatePersonTransactionState extends State<CreatePersonTransaction> {

  DateTime selectedDate = DateTime.now();

  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  final trnDescription = TextEditingController();
  final trnAmount = TextEditingController();
  final personCtrl = TextEditingController();
  var trnTypeValue = 0;

  File? _trnImage;
  late DatabaseHelper handler;
  late Future <List<PersonModel>> persons;
  int selectedCategoryId = 0;
  String categoryType = "activity";

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    persons = handler.getAllPersons();
    handler.initDB().whenComplete(() async {
      setState(() {
        persons = getList();
      });
    });
  }

  //Method to get data from database
  Future<List<PersonModel>> getList() async {
    return await handler.getAllPersons();
  }
  final cFormKey = GlobalKey<FormState>();
  final categoryCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText("add_activity"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ZButton(
                radius: 8,
                width: .35,
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    db.createTransaction(trnDescription.text, selectedCategoryId, widget.person!.pId??1, double.parse(trnAmount.text), _trnImage?.path??"",selectedDate.toIso8601String()).whenComplete(() => Navigator.of(context).pop(true));
                    print("Here issssssss ${_trnImage.toString()}");
                  }
                },
                label: "create"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: zPrimaryColor,
                                borderRadius: BorderRadius.circular(100)
                            ),
                            child: const Icon(Icons.date_range,size: 25,color: Colors.white,)),
                        title: InkWell(
                          onTap: ()=>setState(() {
                            showGregorianPicker();
                          }),
                          child: Text(
                            Env.gregorianDateTimeForm(selectedDate.toString()),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        subtitle: InkWell(
                            onTap: ()=>
                                setState(() {
                                  showPersianPicker(); }),
                            child: Text(
                              Env.persianDateTimeFormat(selectedDate),style: const TextStyle(fontSize: 15),)),
                      ),
                    ),

                  ],
                ),


                ListTile(
                  subtitle: const LocaleText("beneficiary"),
                  leading: const Icon(Icons.person),
                  title: Text(widget.person!.pName??""),
                ),
                //Select Category
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 10),
                    height: 60,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: zPrimaryColor,
                            width: 1.5
                        ),
                        borderRadius: BorderRadius.circular(8)),
                    child: DropdownSearch<CategoryModel>(

                      validator: (value){
                        if(value == null){
                          return Locales.string(context, "category_required");
                        }
                        return null;
                      },
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
                                  color: Colors.grey,
                                  borderRadius:
                                  BorderRadius.circular(15)),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 0, left: 10),
                                child: ListTile(
                                  title: const LocaleText("activity_category",style: TextStyle(fontSize: 18),),
                                  leading: const Icon(Icons.ac_unit_outlined),
                                  trailing: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.circular(50)
                                    ),
                                    child: IconButton(
                                        onPressed: ()=>addCategory(context),
                                        icon: const Icon(Icons.add,color: Colors.white,size: 18)),
                                  ),
                                )
                            ),
                          ],
                        ),

                      ),
                      asyncItems: (value) => db.getCategoryByType("activity"),
                      itemAsString: (CategoryModel u) =>
                          Locales.string(context, u.cName??""),
                      onChanged: (CategoryModel? data) {
                        setState(() {
                          selectedCategoryId = data!.cId!.toInt();
                        });
                      },

                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            hintStyle: const TextStyle(fontSize: 15,fontFamily: "Dubai"),
                            hintText: Locales.string(context, "category"),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 20),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                ZField(
                  isRequire: true,
                  icon: Icons.currency_rupee_rounded,
                  hint: "amount",
                  controller: trnAmount,
                  keyboardInputType: TextInputType.number,
                  validator: (value){
                    if(value.isEmpty){
                      return Locales.string(context,"amount_required");
                    }
                    return null;
                  }, title: 'amount',
                ),
                ZField(
                  icon: Icons.info,
                  hint: "description",
                  controller: trnDescription,
                  title: 'description',
                ),

                ListTile(
                  contentPadding: const EdgeInsets.only(left: 14,right: 4),

                  visualDensity: const VisualDensity(vertical: -4),
                  leading: const Icon(Icons.attachment_rounded),
                  title: const LocaleText("attachment",style: TextStyle(fontWeight: FontWeight.bold),),
                  trailing: _trnImage != null? IconButton(
                      onPressed: (){
                        setState(() {
                          _trnImage = null;
                        });
                      }, icon: Icon(Icons.clear,size: 18,color: Colors.red.shade900,)):null,
                ),
                //Get Image
                InkWell(
                  onTap: (){
                    getImage(ImageSource.gallery);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Placeholder(
                      strokeWidth: 1,
                      color: zPrimaryColor,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: _trnImage!=null? Image.file(_trnImage!,fit: BoxFit.cover).image:const AssetImage("assets/Photos/gallery.png"),
                            )
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addCategory(context){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Add Category"),
        content: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
            height: 200,
            width: double.maxFinite,
            child: Form(
              key: cFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      validator: (value){
                        if(value!.isEmpty){
                          return Locales.string(context, "category_required");
                        }
                        return null;
                      },
                      controller: categoryCtrl,
                      decoration: InputDecoration(
                          hintText: Locales.string(context, "category_name"),
                          suffixIcon: const Icon(Icons.category_rounded)
                      ),
                    ),
                  ),

                  //Action Buttons
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                            const LocaleText("create")),
                      ],
                    ),
                  )
                ],
              ),
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
      _trnImage = File(pickedFile.path);
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
      lastDate: Jalali(1500, 9),
      initialDate: DateTime.now().toJalali(),
    );
    if(picked != null){
      setState(() {
        selectedDate = picked.toDateTime();
      });
    }
    return picked;
  }

}
