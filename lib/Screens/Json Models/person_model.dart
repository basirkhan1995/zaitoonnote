
class PersonModel{
  final int? pId;
  final String pName;
  final String? pImage;
  final String? createdAt;
  PersonModel({this.pId, required this.pName,this.pImage, this.createdAt});

  factory PersonModel.fromMap(Map<String, dynamic> json) => PersonModel(
    pId: json['pId'],
    pName: json ['pName'],
    pImage: json['pImage'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toMap(){
    return{
      'pId':pId,
      'pName':pName,
      'pImage':pImage,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

}