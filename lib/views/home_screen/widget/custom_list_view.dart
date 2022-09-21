import 'package:celebify/database/firestore_methods.dart';
import 'package:celebify/models/livestream.dart';
import 'package:celebify/utils/constants.dart';
import 'package:celebify/views/broadcast_screen/broadcast_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class GridLayoutForApp extends StatefulWidget {
  @override
  State<GridLayoutForApp> createState() => _GridLayoutForAppState();
}

class _GridLayoutForAppState extends State<GridLayoutForApp> {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<dynamic>(
          stream:
              FirebaseFirestore.instance.collection('livestream').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                LiveStream post =
                    LiveStream.fromMap(snapshot.data.docs[index].data());

                return InkWell(
                  onTap: () async {
                    await FirestoreMethods()
                        .updateViewCount('${post.uid}${post.username}', true);
                    Get.to(
                      BroadcastScreen(
                        isBroadcaster: false,
                        channelId: '${post.uid}${post.username}',
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      buildImageCard(
                          index: index,
                          image: post.image,
                          username: post.username,
                          title: post.title,
                          viewers: post.viewers),
                      const SizedBox(height: 10,),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );

  Widget buildImageCard(
          {required int index,
          required String image,
          required String username,
          required String title,
          required int viewers}) =>
      Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue.shade400,
                  Colors.red.shade300,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                margin: EdgeInsets.zero,
                height: MediaQuery.of(context).size.height * 0.155,
                width: MediaQuery.of(context).size.height * 0.155,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: NetworkImage(
                          image,
                        ),
                        fit: BoxFit.fill)),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: latoBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              Text(
                title,
                style: latoBold.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              Text(
                '$viewers watching',
                style: latoRegular.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ],
          )
        ],
      );
}
