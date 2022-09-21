import 'dart:typed_data';
import 'package:celebify/models/livestream.dart';
import 'package:celebify/database/storage_methods.dart';
import 'package:celebify/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();

  Future<String> startLiveStream(BuildContext context, String title, Uint8List? image) async {
    final user =  Provider.of<UserProvider>(context, listen: false).getUser!;
    String channelId = '';

    try {
      if (title.isNotEmpty && image != null) {
        
        if(!(await _firestore.collection('livestream').doc(user.uid).get()).exists){
          String thumbnailUrl = await _storageMethods.uploadImageToStorage(
              'livestream-thumbnails', image, user.uid!);

          channelId = '${user.uid}${user.username}';

          LiveStream liveStream = LiveStream(
              title: title,
              image: thumbnailUrl,
              uid: user.uid!,
              username: user.username!,
              viewers: 0,
              channelId: 'test123',
              startedAt: DateTime.now());

          _firestore
              .collection('livestream')
              .doc(channelId)
              .set(liveStream.toMap());
        }else{
          // print('two live streams going on');
        }
      } else {
        // print('Please enter all the fields');
      }
    } on FirebaseException catch (e) {
       debugPrint(e.message);
    }
    return channelId;
  }

  Future<void> endLiveStream(String channelId) async {
    try{
      await _firestore.collection('livestream').doc(channelId).delete();
    }catch(e){
      debugPrint(e.toString());
    }
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try{
      await _firestore.collection('livestream').doc(id).update({
        'viewers' : FieldValue.increment(isIncrease ? 1 : -1),
      });
    }catch(e){
      debugPrint(e.toString());
    }
  }

}
