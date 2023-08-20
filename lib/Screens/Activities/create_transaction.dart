
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Methods/z_button.dart';
import 'package:zaitoonnote/Methods/z_field.dart';
import 'package:zaitoonnote/Screens/Persons/add_person.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../Json Models/category_model.dart';
import '../Json Models/person_model.dart';
import 'dart:io';

class CreateTransaction extends StatefulWidget {
  const CreateTransaction({super.key});

  @override
  State<CreateTransaction> createState() => _CreateTransactionState();
}

class _CreateTransactionState extends State<CreateTransaction> {
  final formKey = GlobalKey<FormState>();
  final db = DatabaseHelper();
  final trnDescription = TextEditingController();
  final trnAmount = TextEditingController();
  final personCtrl = TextEditingController();
  int selectedPerson = 0;
  var trnTypeValue = 0;
  File? trnImagePath;
  late DatabaseHelper handler;
  late Future <List<PersonModel>> persons;
  int selectedCategoryId = 0;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    persons = handler.getPersons();
    handler.initDB().whenComplete(() async {
      setState(() {
        persons = getList();
      });
    });
  }


  //Method to get data from database
  Future<List<PersonModel>> getList() async {
    return await handler.getPersons();
  }
 final cFormKey = GlobalKey<FormState>();
  final categoryCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final dt = DateTime.now();

    //Gregorian Date format
    final gregorianDate = DateFormat('dd/MM/yyyy - HH:mm a').format(dt);
    Jalali persianDate = dt.toJalali();

    //Persian Date format
    String shamsiDate() {
      final f = persianDate.formatter;
      return '${f.yyyy}/${f.mm}/${f.dd}';
    }

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
                    db.createTransaction2(trnDescription.text, selectedCategoryId, selectedPerson, int.parse(trnAmount.text), trnImagePath.toString()).whenComplete(() => Navigator.pop(context));
                  }
                },
                label: "create"),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(
                          gregorianDate,
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(shamsiDate(),style: const TextStyle(fontSize: 15),),
                      ),
                    ),

                  ],
                ),


             //Select Person and Category
                Row(
                  children: [

                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 8),
                        child: DropdownSearch<PersonModel>(
                          dropdownButtonProps: const DropdownButtonProps(
                            icon: Icon(Icons.arrow_drop_down_rounded)
                          ),
                          enabled: true,
                          validator: (value){
                            if(value == null){
                              return Locales.string(context, "person_required");
                            }
                            return null;
                          },
                          asyncItems: (value) => db.getPersonsByID(value),
                          itemAsString: (PersonModel u) => u.pName.toString(),
                          onChanged: (PersonModel? data){
                            selectedPerson = data!.pId!.toInt();
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(

                            dropdownSearchDecoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.deepPurple,
                                    width: 1.8
                                  )
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    width: 1.5,
                                    color: zPurple
                                  )
                                ),
                                labelText: Locales.string(context, "person_hint")),
                          ),
                          popupProps: PopupPropsMultiSelection.menu(
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: Locales.string(context,"search"),
                                border: const UnderlineInputBorder(),
                                suffixIcon: IconButton(
                                    onPressed: ()=>Env.goto(const AddPerson(), context),
                                    icon: const Icon(Icons.add,color: Colors.black,size: 18)),
                              )
                            ),
                            showSearchBox: true,
                            fit: FlexFit.loose,


                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 10),
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: DropdownSearch<CategoryModel>(
                            validator: (value){
                              if(value == null){
                                return Locales.string(context, "category_required");
                              }
                              return null;
                            },
                            popupProps: PopupPropsMultiSelection.bottomSheet(
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
                                              onPressed: ()=>addCategory(context),
                                              icon: const Icon(Icons.add,color: Colors.white,size: 18)),
                                        ),
                                      )
                                  ),
                                ],
                              ),

                            ),

                            asyncItems: (value) => db.getCategoryById(value),
                            itemAsString: (CategoryModel u) =>
                                Locales.string(context, u.cName),
                            onChanged: (CategoryModel? data) {
                              setState(() {
                                selectedCategoryId = data!.cId!.toInt();
                              });
                            },
                            dropdownButtonProps: const DropdownButtonProps(
                              icon: Icon(Icons.arrow_drop_down_circle_outlined, size: 22),
                            ),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                  hintStyle: const TextStyle(fontSize: 13),
                                  hintText: Locales.string(
                                      context, "select_category"),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 20),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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


                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Placeholder(
                   strokeWidth: 1,
                    color: zPurple,
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
                                db.createCategory(CategoryModel(cName: categoryCtrl.text)).whenComplete(() => Navigator.pop(context));
                              }
                            },
                            child:
                            const LocaleText(
                                "create")),
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
}
