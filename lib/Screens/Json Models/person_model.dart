
class PersonModel{
  final int? pId;
  final String pName;
  final String? pImage;
  final String? pPhone;
  final String? createdAt;
  PersonModel({this.pId, required this.pName,this.pImage,this.pPhone, this.createdAt});

  factory PersonModel.fromMap(Map<String, dynamic> json) => PersonModel(
    pId: json['pId'],
    pName: json ['pName'],
    pImage: json['pImage'],
    pPhone: json['pPhone'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toMap(){
    return{
      'pId':pId,
      'pName':pName,
      'pImage':pImage,
      'pPhone':pPhone,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

}