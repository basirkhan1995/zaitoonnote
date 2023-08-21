
class PersonModel{
  final int? pId;
  final String pName;
  final String cardNumber;
  final String accountName;
  final String jobTitle;
  final String? pImage;
  final String? pPhone;
  final String? createdAt;
  PersonModel({this.pId, required this.pName,required this.jobTitle,required this.cardNumber,required this.accountName, this.pImage,this.pPhone, this.createdAt});

  factory PersonModel.fromMap(Map<String, dynamic> json) => PersonModel(
    pId: json['pId'],
    pName: json ['pName'],
    cardNumber: json['cardNumber'],
    accountName: json['accountName'],
    jobTitle: json['jobTitle'],
    pImage: json['pImage'],
    pPhone: json['pPhone'],
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
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

}