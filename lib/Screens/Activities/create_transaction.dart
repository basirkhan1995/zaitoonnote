import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/textfield.dart';
import '../Json Models/category_model.dart';
import '../Json Models/person_model.dart';

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
  late DatabaseHelper handler;
  late Future <List<PersonModel>> persons;
  var selectedCategoryName = "";

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
    final gregorianDate = DateFormat('yyyy-MM-dd (HH:mm a)').format(dt);
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
            child: TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    db.createTransaction2(trnDescription.text, selectedCategoryName, selectedPerson, int.parse(trnAmount.text)).whenComplete(() => Navigator.pop(context));
                  }
                },
                child: const LocaleText("create")),
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
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(shamsiDate()),
                      ),
                    ),

                  ],
                ),

                Padding(
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
                          Locales.string(context, u.cName.toString()),
                      onChanged: (CategoryModel? data) {
                        setState(() {
                          selectedCategoryName = data!.cName;
                        });
                      },
                      dropdownButtonProps: const DropdownButtonProps(
                        icon: Icon(Icons.arrow_drop_down_circle_outlined, size: 22),
                      ),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              onPressed: (){
                               setState(() {
                                 personCtrl.clear();
                                 addPerson(context);
                               });
                              },
                              icon: const Icon(Icons.add,color: Colors.black,size: 18)),
                        )
                      ),
                      showSearchBox: true,
                      fit: FlexFit.loose,


                    ),
                  ),
                ),
                UnderlineInputField(
                  hint: "amount",
                  controller: trnAmount,
                  inputType: TextInputType.number,
                  validator: (value){
                    if(value.isEmpty){
                      return Locales.string(context,"amount_required");
                    }
                    return null;
                  },
                ),
                IntrinsicHeight(
                  child: ConstrainedBox(
                    constraints:  const BoxConstraints(
                      minHeight: 250,
                      maxHeight: 500,
                    ),
                    child: UnderlineInputField(
                      validator: (value){
                        if(value.isEmpty){
                          return Locales.string(context,"description_required");
                        }
                        return null;
                      },
                      hint: "description",
                      controller: trnDescription,
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
      ),
    );
  }

  void addPerson(context){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const LocaleText("add_person"),
        content: SizedBox(
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
                        return Locales.string(context, "name_required");
                      }
                      return null;
                    },
                    controller: personCtrl,
                    decoration: InputDecoration(
                        hintText: Locales.string(context, "name"),
                        suffixIcon: const Icon(Icons.person)
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
                              db.createPerson(PersonModel(pName: personCtrl.text)).whenComplete(() => Navigator.pop(context));
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
      );
    });
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
