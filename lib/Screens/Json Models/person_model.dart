
class PersonModel{
  final int? pId;
  final String? pName;
  final String cardNumber;
  final String accountName;
  final String jobTitle;
  final String? pImage;
  final String? pPhone;
  final String? updatedAt;
  final String? createdAt;
  PersonModel({this.pId, this.pName,required this.jobTitle,required this.cardNumber,required this.accountName, this.pImage,this.pPhone, this.createdAt, this.updatedAt});

  factory PersonModel.fromMap(Map<String, dynamic> json) => PersonModel(
    pId: json['pId'],
    pName: json ['pName'],
    cardNumber: json['cardNumber'],
    accountName: json['accountName'],
    jobTitle: json['jobTitle'],
    pImage: json['pImage'],
    pPhone: json['pPhone'],
    updatedAt: json['updatedAt'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toMap(){
    return{
      'pId':pId,
      'pName':pName,
      'cardNumber':cardNumber,
      'accountName':accountName,
      'jobTitle':jobTitle,
      'pImage':pImage,
      'pPhone':pPhone,
      'updatedAt': updatedAt??DateTime.now().toIso8601String(),
      'createdAt': createdAt??DateTime.now().toIso8601String(),
    };
  }

}