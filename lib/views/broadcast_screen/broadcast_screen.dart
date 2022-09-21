import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:celebify/database/firestore_methods.dart';
import 'package:celebify/models/livestream.dart';
import 'package:celebify/provider/user_provider.dart';
import 'package:celebify/config/config.dart';
import 'package:celebify/utils/constants.dart';
import 'package:celebify/views/home_screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:get/route_manager.dart';

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  const BroadcastScreen(
      {Key? key,
      required this.isBroadcaster,
      required this.channelId})
      : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  void _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appID));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      // print('he is a braodcaster');
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      // print('he is a audience');
      _engine.setClientRole(ClientRole.Audience);
    }

    _joinChannel();
  }

  void _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine.joinChannelWithUserAccount(tempToken, 'test123',
        Provider.of<UserProvider>(context, listen: false).getUser!.uid!);
  }

  void _addListeners() {
    _engine.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
      debugPrint('joinChannelSuccess  $uid $elapsed');
    }, userJoined: (uid, elapsed) {
      debugPrint('userJoined $uid $elapsed');
      setState(() {
        remoteUid.add(uid);
      });
    }, userOffline: (uid, reason) {
      debugPrint('userOffline $uid $reason');
      setState(() {
        remoteUid.removeWhere((element) => element == uid);
      });
    }, leaveChannel: (stats) {
      debugPrint('leaveChannel $stats');
      setState(() {
        remoteUid.clear();
      });
    }));
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    if (widget.isBroadcaster) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }
    Get.off(HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        body: Column(
          children: [
            StreamBuilder<dynamic>(
                stream: FirebaseFirestore.instance
                    .collection('livestream')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: SafeArea(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Connecting...',
                                style: latoBold.copyWith(
                                    color: Colors.black, fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  LiveStream post = LiveStream.fromMap(
                      snapshot.data.docs[0].data());
                  print('==========================> hello ${post.viewers}');
                  return Expanded(
                    child: Stack(
                      children: [
                        _renderVideo(user),
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: 50,
                              width: 80,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.white),
                                    const VerticalDivider(
                                      color: Colors.white,
                                    ),
                                    Text(
                                      post.viewers.toString(),
                                      style: latoBold.copyWith(
                                          color: Colors.white, fontSize: 20),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },),
            if (widget.isBroadcaster)
              SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMuted = !isMuted;
                        });
                        onToggleMute;
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(const CircleBorder()),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(20)),
                        backgroundColor: MaterialStateProperty.all(
                            isMuted == true ? Colors.red : Colors.blue),
                      ),
                      child: const Icon(Icons.mic_off),
                    ),
                    ElevatedButton(
                      onPressed: () => _switchCamera(),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(const CircleBorder()),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(20)),
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      child: const Icon(Icons.flip_camera_android),
                    ),
                    ElevatedButton(
                      onPressed: () => _leaveChannel(),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(const CircleBorder()),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(20)),
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      child: const Icon(Icons.close),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  _renderVideo(user) {
    // print('this is the remote uid ======> ${remoteUid.isNotEmpty}');
    return widget.isBroadcaster
        ? const RtcLocalView.SurfaceView(
            zOrderMediaOverlay: true,
            zOrderOnTop: true,
          )
        : remoteUid.isNotEmpty
            ? RtcRemoteView.TextureView(
                uid: remoteUid[0],
                channelId: 'test123',
              )
            : Container();
  }

  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }
}
