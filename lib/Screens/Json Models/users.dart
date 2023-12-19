
class UsersModel{
  final int? usrId;
  final String? fullName;
  final String? phone;
  final String usrName;
  final String usrPassword;
  UsersModel({this.usrId, required this.usrName,required this.usrPassword,this.fullName, this.phone});

  factory UsersModel.fromMap(Map<String, dynamic> json) => UsersModel(
      usrId: json['usrId'],
      usrName: json ['usrName'],
      usrPassword: json['usrPassword'],
      fullName:json['fullName'],
      phone: json['phone'],
  );

  Map<String, dynamic> toMap(){
    return{
      'usrId':usrId,
      'usrName':usrName,
      'usrPassword':usrPassword,
      'fullName' :fullName,
      'phone':phone,
    };
  }

}