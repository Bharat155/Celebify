import 'package:celebify/database/auth_methods.dart';
import 'package:celebify/models/user_model.dart';
import 'package:celebify/provider/user_provider.dart';
import 'package:celebify/utils/constants.dart';
import 'package:celebify/views/home_screen/home_screen.dart';
import 'package:celebify/views/login_screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {

  final AuthMethods _authMethods = AuthMethods();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider())
      ],
      child: Consumer(
        builder: (context, _, child){
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: FutureBuilder(
              future: _authMethods
                  .getCurrentUser(FirebaseAuth.instance.currentUser != null
                  ? FirebaseAuth.instance.currentUser!.uid
                  : null)
                  .then((value) {
                if (value != null) {
                  Provider.of<UserProvider>(context, listen: false).setUser(
                    UserModel.fromMap(value as Map<String, dynamic>),
                  );
                }
                return value;
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                if (snapshot.hasData) {
                  return  HomeScreen();
                }
                return  LoginScreen();
              },
            ),
          );
        },
      ),
        );
  }
}

