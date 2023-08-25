
import 'package:intl/intl.dart';

class CategoryModel{
  final int? cId;
  final String? cName;
  final String? categoryType;
  final String? createdAt;
  CategoryModel({this.cId, required this.cName,required this.categoryType, this.createdAt});

  factory CategoryModel.fromMap(Map<String, dynamic> json) => CategoryModel(
    cId: json['cId'],
    cName: json ['cName'],
    categoryType: json['categoryType'],
    createdAt: json['catCreatedAt'],
  );

  Map<String, dynamic> toMap(){
    return{
      'cId':cId,
      'cName':cName,
      'categoryType':categoryType,
      'catCreatedAt': createdAt??DateTime.now().toIso8601String(),
    };
  }

}