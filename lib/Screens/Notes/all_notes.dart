import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zaitoonnote/Screens/Json%20Models/category_model.dart';
import '../../Datebase Helper/sqlite.dart';
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

  late DatabaseHelper handler;
  late Future<List<Notes>> notes;
  late Future<List<CategoryModel>> category;

  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    handler = DatabaseHelper();
    notes = handler.getNotes();
    category = handler.getCategories();

    handler.initDB().whenComplete(() async {
      setState(() {
        notes = getList();
        category = getCategories();
      });
    });
  }

  //Method to get data from database
  Future<List<Notes>> getList() async {
    return await handler.getNotes();
  }

  //Method to get data from database
  Future<List<CategoryModel>> getCategories() async {
    return await handler.getCategories();
  }

  //Method to refresh data on pulling the list
  Future<void> _onRefresh() async {
    setState(() {
      notes = getList();
      category = getCategories();
    });
  }

  var filterTitle = ["all", "work", "payment", "received", "meeting"];
  var filterData = ["%", "work", "payment", "received", "meeting"];
  int currentFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MyProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          controller.darkLight ? Colors.grey.withOpacity(.3) : Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateNote()));
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //Filter buttons
            SizedBox(
              height: 50,
              child: FutureBuilder<List<CategoryModel>>(
                future: category,
                builder: (BuildContext context, AsyncSnapshot<List<CategoryModel>> snapshot) {
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
                            // MaterialButton(
                            //   shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(4)),
                            //   minWidth: 100,
                            //   color: Theme.of(context).colorScheme.inversePrimary,
                            //   onPressed: () => _onRefresh(),
                            //   child: const LocaleText("refresh"),
                            // )
                          ],
                        ));
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
                               notes = db.filterMemo(items[index].cName);
                             });
                           },
                          child: Container(
                              margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  color: currentFilterIndex == index? Colors.deepPurple.withOpacity(.1): Colors.transparent,
                                 ),
                              child: Center(
                                child: LocaleText(
                                  items[index].cName,
                                  style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 15,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              )),
                        );
                      },
                    );
                  }
                }
              ),
            ),

            //Search TextField
            Container(
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
                    notes = db.searchMemo(keyword);
                  });
                },
                decoration: InputDecoration(
                    hintText: Locales.string(context, "search"),
                    icon: const Icon(Icons.search),
                    border: InputBorder.none),
              ),
            ),

            //Notes to show
            Expanded(
              child: SafeArea(
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
                          // MaterialButton(
                          //   shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(4)),
                          //   minWidth: 100,
                          //   color: Theme.of(context).colorScheme.inversePrimary,
                          //   onPressed: () => _onRefresh(),
                          //   child: const LocaleText("refresh"),
                          // )
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
                              final dt = DateTime.parse(
                                  items[index].createdAt.toString());
                              final noteDate =
                                  DateFormat('yyyy-MM-dd (HH:mm a)').format(dt);
                              //Dismissible widget is to delete a data on pushing a record from left to right
                              return Dismissible(
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade900,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      LocaleText(
                                        "delete",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                                key: ValueKey<int>(items[index].noteId!),
                                onDismissed:
                                    (DismissDirection direction) async {
                                  await handler
                                      .setNoteStatus(items[index].noteId)
                                      .whenComplete(() => ScaffoldMessenger.of(
                                              context)
                                          .showSnackBar(SnackBar(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration: const Duration(
                                                  milliseconds: 900),
                                              content: const LocaleText(
                                                "deletemsg",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ))));
                                  setState(() {
                                    items.remove(items[index]);
                                    _onRefresh();
                                  });
                                },
                                child: InkWell(
                                  onTap: () {
                                    //To hold the data in text fields for update method
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => NoteDetails(
                                                  details: items[index],
                                                )));
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      padding: const EdgeInsets.all(8),
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: controller.darkLight
                                              ? Colors.black
                                              : Colors.deepPurple
                                                  .withOpacity(.6),
                                          boxShadow: const [
                                            BoxShadow(
                                                blurRadius: 1,
                                                color: Colors.grey)
                                          ]),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                items[index].noteTitle,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          color: Colors.white),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 4,
                                                          vertical: 4),
                                                      child: LocaleText(
                                                        items[index].category!,
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .deepPurple,
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Flexible(
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 13.0),
                                                  child: Text(
                                                    items[index].noteContent,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ))),
                                          Expanded(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(noteDate,
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          )),
                                        ],
                                      )),
                                ),
                              );
                            },
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: (5 / 3),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
