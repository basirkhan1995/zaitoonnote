
class UsersModel{
  final int? usrId;
  final String usrName;
  final String usrPassword;
  final int? personInfo;
  UsersModel({this.usrId, required this.usrName,required this.usrPassword,this.personInfo});

  factory UsersModel.fromMap(Map<String, dynamic> json) => UsersModel(
    usrId: json['usrId'],
    usrName: json ['usrName'],
    usrPassword: json['usrPassword'],
    personInfo:json['personInfo']
  );

  Map<String, dynamic> toMap(){
    return{
      'usrId':usrId,
      'usrName':usrName,
      'usrPassword':usrPassword,
      'personInfo' :personInfo,
    };
  }

}