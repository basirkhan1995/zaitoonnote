
class CategoryModel{
  final int? cId;
  final String cName;
  final String? createdAt;
  CategoryModel({this.cId, required this.cName,this.createdAt});

  factory CategoryModel.fromMap(Map<String, dynamic> json) => CategoryModel(
    cId: json['cId'],
    cName: json ['cName'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toMap(){
    return{
      'cId':cId,
      'cName':cName,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

}