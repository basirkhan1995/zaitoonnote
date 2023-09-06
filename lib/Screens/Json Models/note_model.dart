

class Notes{
  final int? noteId;
  final int? cId;
  final int? color;
  final String noteTitle;
  final String noteContent;
  final int? noteStatus;
  final String? category;
  final String? createdAt;
  Notes({this.noteId, required this.noteTitle, required this.noteContent, this.noteStatus = 1,this.color, this.category,this.cId, this.createdAt});

  factory Notes.fromMap(Map<String, dynamic> json) => Notes(
    noteId: json['noteId'],
    cId: json['cId'],
    color: json['color'],
    noteTitle: json ['noteTitle'],
    noteContent: json['noteContent'],
    noteStatus: json['noteStatus'],
    category: json['cName'],
    createdAt: json['noteCreatedAt'],
  );

  Map<String, dynamic> toMap(){
    return{
      'noteId':noteId,
      'cId':cId,
      'color':color,
      'noteTitle': noteTitle,
      'noteContent':noteContent,
      'noteStatus':noteStatus,
      'cName':category,
      'noteCreatedAt': createdAt??DateTime.now().toIso8601String(),
    };
  }

}