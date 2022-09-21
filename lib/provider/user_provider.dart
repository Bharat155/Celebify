import 'package:celebify/models/user_model.dart';
import 'package:flutter/widgets.dart';

class UserProvider with ChangeNotifier{
  UserModel _user = UserModel(
    email: '',
    username: '',
    uid: '',
  );

  UserModel? get getUser => _user;

  setUser(UserModel user){
    _user = user;
    notifyListeners();
  }

}
