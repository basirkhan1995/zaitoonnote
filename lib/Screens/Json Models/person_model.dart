
class PersonModel{
  final int? pId;
  final String pName;
  final String? createdAt;
  PersonModel({this.pId, required this.pName,this.createdAt});

  factory PersonModel.fromMap(Map<String, dynamic> json) => PersonModel(
    pId: json['pId'],
    pName: json ['pName'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toMap(){
    return{
      'pId':pId,
      'pName':pName,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

}