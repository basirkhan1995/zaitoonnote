

class TransactionModel{
  final int? trnId;
  final String trnCategory;
  final String trnDescription;
  final int amount;
  final String person;
  final String? pImage;
  final String? trnImage;
  final String? createdAt;
  TransactionModel({this.trnId, required this.trnCategory, this.pImage, this.trnImage, required this.trnDescription, required this.amount,required this.person,this.createdAt});

  factory TransactionModel.fromMap(Map<String, dynamic> json) => TransactionModel(
    trnId: json['trnId'],
    trnCategory: json ['cName'],
    pImage: json['pImage'],
    trnImage: json['trnImage'],
    trnDescription: json['trnDescription'],
    amount: json['amount'],
    person: json['pName'],
    createdAt: json['trnDate'],
  );

  Map<String, dynamic> toMap(){
    return{
      'trnId':trnId,
      'cName': trnCategory,
      'pImage': pImage,
      'trnImage': trnImage,
      'trnDescription':trnDescription,
      'amount':amount,
      'pName':person,
      'trnDate': DateTime.now().toIso8601String(),
    };
  }

}