import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:zaitoonnote/Methods/colors.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import '../../Datebase Helper/sqlite.dart';
import '../../Methods/env.dart';
import '../../Provider/provider.dart';
import '../Json Models/note_model.dart';
import 'create_note.dart';
import 'note_details.dart';

class AllNotes extends StatefulWidget {
  const AllNotes({super.key});

  @override
  State<AllNotes> createState() => _AllNotesState();
}

class _AllNotesState extends State<AllNotes> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final searchCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String keyword = "";
  String noteTypeCategory = "note";

  late DatabaseHelper handler;
  late Future<List<Notes>> notes;
  late Future<List<CategoryModel>> category;

  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    notes = handler.getAllNotes();
    category = handler.getCategories(noteTypeCategory);

    handler.initDB().whenComplete(() async {
      setState(() {
        notes = getList();
        category = getCategories();
      });
    });
  }

  //Method to get data from database
  Future<List<Notes>> getList() async {
    return await handler.getAllNotes();
  }


  //Method to get data from database
  Future<List<CategoryModel>> getCategories() async {
    return await handler.getCategories(noteTypeCategory);
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      notes = getList();
      category = getCategories();
    });
  }


  int currentFilterIndex = 0;

  bool isFilterTrue = false;
  bool isSearchTrue = false;
  String refresh = 'refresh';

  @override
  Widget build(BuildContext context) {
    String currentLocale = Locales.currentLocale(context).toString();
    final controller = Provider.of<MyProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          controller.darkLight ? Colors.grey.withOpacity(.3) : Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateNote()));
         if(refresh.isNotEmpty && refresh == 'refresh'){
          _onRefresh();
         }
        },

        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const LocaleText("notes",style: TextStyle(fontSize: 24,fontFamily: "Ubuntu",fontWeight: FontWeight.bold),),
              trailing: Wrap(
                spacing: 10,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: zPrimaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: IconButton(
                      onPressed: (){
                      setState(() {
                        isFilterTrue = !isFilterTrue;
                      });
                    },icon: const Icon(Icons.filter_alt,size: 18),),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: zPrimaryColor.withOpacity(.1),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: IconButton(onPressed: (){
                      setState(() {
                        isSearchTrue = !isSearchTrue;
                      });
                    },icon: const Icon(Icons.search,size: 18),),
                  ), // icon-1

                ],
              ),
            ),

            //Filter buttons
        isFilterTrue? SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width *.95,
              child: FutureBuilder<List<CategoryModel>>(
                future: category,
                builder: (BuildContext context, AsyncSnapshot<List<CategoryModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                    //If snapshot has error
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    //a final variable (item) to hold the snapshot data
                    final items = snapshot.data ?? <CategoryModel>[];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          splashColor: Colors.transparent,
                           onTap: (){
                             setState(() {
                               currentFilterIndex = index;
                               notes = db.getFilteredNotes(items[index].cName??"");
                             });
                           },
                          child: Container(
                              margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  color: currentFilterIndex == index? Colors.deepPurple.withOpacity(.5): Colors.deepPurple.withOpacity(.1),
                                 ),
                              child: Center(
                                child: LocaleText(
                                  items[index].cName??"",
                                  style: TextStyle(
                                      color: currentFilterIndex == index? Colors.white: Colors.deepPurple,
                                      fontSize: 14,
                                      fontWeight: currentFilterIndex == index? FontWeight.bold: FontWeight.w400),
                                ),
                              )),
                        );
                      },
                    );
                  }
                }
              ),
            ):const SizedBox(),

            //Search TextField
           isSearchTrue? Container(
             width: MediaQuery.of(context).size.width *.93,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: controller.darkLight
                      ? Colors.black12
                      : Colors.deepPurple.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8)),
              child: TextFormField(
                controller: searchCtrl,
                onChanged: (value) {
                  setState(() {
                    keyword = searchCtrl.text;
                    notes = db.searchNote(keyword);
                  });
                },
                decoration: InputDecoration(
                    hintText: Locales.string(context, "search"),
                    icon: const Icon(Icons.search),
                    border: InputBorder.none),
              ),
            ):const SizedBox(),

            //All Notes
            Expanded(
              child: SafeArea(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *.97,
                  child: FutureBuilder<List<Notes>>(
                    future: notes,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Notes>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          //To show a circular progress indicator
                          child: CircularProgressIndicator(),
                        );
                        //If snapshot has error
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/Photos/empty.png", width: 250),
                          ],
                        ));
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        //a final variable (item) to hold the snapshot data
                        final items = snapshot.data ?? <Notes>[];
                        return Scrollbar(
                          //The refresh indicator
                          child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              shrinkWrap: true,
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int index) {
                              
                                return InkWell(
                                  splashColor: Colors.white,
                                  onTap: () async{
                                    //To hold the data in text fields for update method
                                    refresh = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => NoteDetails(
                                                  details: items[index],
                                                )));

                                   if(refresh == 'refresh'){
                                     _onRefresh();
                                   }
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      padding: const EdgeInsets.all(12),
                                      width: MediaQuery.of(context).size.width / 2,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: controller.darkLight
                                              ? Colors.black
                                              : Color(items[index].color??zPrimaryColor.value),
                                        ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                items[index].noteTitle,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",
                                                    fontWeight: FontWeight.bold),
                                              ),

                                            ],
                                          ),

                                          Flexible(
                                              child: SizedBox(
                                                height: double.infinity,
                                                  child: Text(
                                                    items[index].noteContent,
                                                    style: TextStyle(
                                                        fontFamily: currentLocale == "en"?"Ubuntu":"Dubai",
                                                        color: Colors.white),
                                                    overflow: TextOverflow.ellipsis,
                                                  ))),

                                          Expanded(
                                              child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(currentLocale == "en"?Env.gregorianDateTimeForm(items[index].createdAt.toString()):Env.persianDateTimeFormat(DateTime.parse(items[index].createdAt.toString())),
                                                  style: const TextStyle(
                                                      color: Colors.white,fontWeight: FontWeight.bold)),
                                            ],
                                          )),
                                        ],
                                      )),
                                );
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: (5 / 4),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
