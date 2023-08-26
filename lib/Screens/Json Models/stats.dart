
class TransactionStats{
  final int? totalPaid;
  final int? totalReceived;
  final int? totalChecks;
  final int? totalPowerBill;
  final int? totalRent;
  TransactionStats({this.totalPaid, this.totalReceived,this.totalChecks,this.totalPowerBill,this.totalRent});

  factory TransactionStats.fromMap(Map<String, dynamic> json) => TransactionStats(
      totalPaid: json['paid'],
      totalReceived: json ['received'],
      totalChecks: json['check'],
      totalPowerBill: json['power'],
      totalRent: json['rent']
  );

  Map<String, dynamic> toMap(){
    return{
      'paid':totalPaid,
      'received':totalReceived,
      'check':totalChecks,
      'power' :totalPowerBill,
      'rent' :totalRent,
    };
  }

}