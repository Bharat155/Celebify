import 'package:celebify/database/auth_methods.dart';
import 'package:celebify/database/firestore_methods.dart';
import 'package:celebify/models/livestream.dart';
import 'package:celebify/utils/constants.dart';
import 'package:celebify/views/broadcast_screen/broadcast_screen.dart';
import 'package:celebify/views/go_live/onboarding_for_live.dart';
import 'package:celebify/views/home_screen/widget/custom_list_view.dart';
import 'package:celebify/views/login_screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/route_manager.dart';


class HomeScreen extends StatefulWidget{
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Celebify",
            style: latoBold.copyWith(
                fontSize: 48,  color: Colors.black),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.output),
                color: Colors.black,
                onPressed: ()  async {
                  showAlertDialog(context);
                }),]
      ),
      body: GridLayoutForApp(),
      floatingActionButton: GestureDetector(
        onTap: () => Get.to(OnboardingScreen()),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 105,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    height: 72,
                    width: 75,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Lottie.asset("assets/live.json"),
                  ),
                ),
                Text(
                  "Go Live",
                  style: latoBold.copyWith(
                      fontSize: 18
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget stayButton = TextButton(
      child: const Text("Stay"),
      onPressed:  () => Get.back(),
    );
    Widget leaveButton = TextButton(
      child: const Text("Leave"),
      onPressed:  () async {
        final bool isLoggedOut = await AuthMethods().signOutOfGoogle();
        if(isLoggedOut){
          ///navigate the user to login screen such that he/she is not able to back by tapping the back button
          Get.offAll(LoginScreen());
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Don't you want to stay ?"),
      actions: [
        leaveButton,
        stayButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
