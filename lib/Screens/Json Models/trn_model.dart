
class TransactionModel{
  final int? trnId;
  final String trnCategory;
  final String trnDescription;
  final int amount;
  final String? person;
  final String? createdAt;
  TransactionModel({this.trnId, required this.trnCategory, required this.trnDescription, required this.amount,required this.person,this.createdAt});

  factory TransactionModel.fromMap(Map<String, dynamic> json) => TransactionModel(
    trnId: json['trnId'],
    trnCategory: json ['trnType'],
    trnDescription: json['trnDescription'],
    amount: json['amount'],
    person: json['pName'],
    createdAt: json['trnDate'],
  );

  Map<String, dynamic> toMap(){
    return{
      'trnId':trnId,
      'trnType': trnCategory,
      'trnDescription':trnDescription,
      'amount':amount,
      'pName':person,
      'trnDate': DateTime.now().toIso8601String(),
    };
  }

}