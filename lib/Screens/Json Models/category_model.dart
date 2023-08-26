
class CategoryModel{
  final int? cId;
  final String? cName;
  final String? categoryType;

  CategoryModel({this.cId, required this.cName,required this.categoryType});

  factory CategoryModel.fromMap(Map<String, dynamic> json) => CategoryModel(
    cId: json['cId'],
    cName: json ['cName'],
    categoryType: json['categoryType'],
  );

  Map<String, dynamic> toMap(){
    return{
      'cId':cId,
      'cName':cName,
      'categoryType':categoryType,
    };
  }

}