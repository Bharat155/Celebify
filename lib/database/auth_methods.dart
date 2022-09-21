import 'dart:async';
import 'package:celebify/models/user_model.dart';
import 'package:celebify/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final CollectionReference _userCollection = firestore.collection('users');
  UserModel userModel = UserModel();



  Future<Object?> getCurrentUser(String? uid) async {
    if (uid != null) {
      final snap = await _userCollection.doc(uid).get();
      return snap.data();
    }
    return null;
  }


  Future<UserCredential?> signInWithGoogle(BuildContext context)async{
    UserCredential? res;
    try{
      GoogleSignInAccount? _signInAccount = await (_googleSignIn.signIn());
      GoogleSignInAuthentication _signInAuthentication = await _signInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: _signInAuthentication.accessToken,
          idToken: _signInAuthentication.idToken
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if(userCredential.user != null){
        UserModel userModel = UserModel(
            email: userCredential.user!.email,
            username: getUsername(userCredential.user!.email!),
            profilePhoto: userCredential.user!.photoURL,
            name: userCredential.user!.displayName,
            uid: userCredential.user!.uid
        );
        Provider.of<UserProvider>(context, listen: false).setUser(userModel);
        res = userCredential;
      }
    } on FirebaseAuthException catch(e){
      print('error in auth $e');
    }
    return res;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await firestore.collection('users').where('email',isEqualTo: user.email).get();

    final List<DocumentSnapshot> docs = result.docs;

    ///if user is registered then length of list >0 or else equal than 0
    return docs.isEmpty ? true:false;
  }

  String getUsername(String email){
    return email.split('@')[0];
  }


  Future<void> addDatatoDB(User currentUser, BuildContext context) async {
    String username = getUsername(currentUser.email!);
    userModel = UserModel(
      uid: currentUser.uid,
      name: currentUser.displayName,
      email: currentUser.email,
      username: username,
      profilePhoto: currentUser.photoURL,
    );

    firestore.collection('users').doc(currentUser.uid).set(userModel.toMap(userModel) as Map<String, dynamic>);

    Provider.of<UserProvider>(context, listen: false).setUser(userModel);
  }

  Future<bool> signOutOfGoogle() async {
    try{
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    }catch(e){
      // print(e);
      return false;
    }
  }

  Future<List<UserModel>> fetchAllUsers(User currentUser)async{
    List<UserModel> userList= [];

    QuerySnapshot querySnapshot = await firestore.collection('users').get();

    for(var i=0; i<querySnapshot.docs.length;i++){
      if(querySnapshot.docs[i].id != currentUser.uid){
        userList.add(UserModel.fromMap(querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }
    return userList;
  }


  Stream<DocumentSnapshot> getUserStream({required String uid}) => _userCollection.doc(uid).snapshots();
}