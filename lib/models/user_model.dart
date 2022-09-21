class UserModel{
  String? uid;
  String? email;
  String? name;
  String? username;
  String? profilePhoto;

  UserModel({
    this.email,
    this.username,
    this.name,
    this.uid,
    this.profilePhoto});

  Map toMap(UserModel user){
    var data = Map<String, dynamic>();
    data['uid']=user.uid;
    data['name']= user.name;
    data['email']= user.email;
    data['username']= user.username;
    data['profile_photo']= user.profilePhoto;
    return data;
  }

  UserModel.fromMap(Map<String, dynamic> mapData){
    uid = mapData['uid'];
    name = mapData['name'];
    email = mapData['email'];
    username = mapData['username'];
    profilePhoto = mapData['profile_photo'];
  }
}