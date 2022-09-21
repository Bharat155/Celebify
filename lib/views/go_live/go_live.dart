import 'dart:io';
import 'dart:typed_data';
import 'package:celebify/database/firestore_methods.dart';
import 'package:celebify/permissions/permissions.dart';
import 'package:celebify/utils/constants.dart';
import 'package:celebify/views/broadcast_screen/broadcast_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List? image;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  goLiveStream() async {
    await Permissions.cameraAndMicrophonePermissionsGranted();
    String channelId = await FirestoreMethods()
        .startLiveStream(context, _titleController.text, image);

    if (channelId.isNotEmpty) {
      Get.to(BroadcastScreen(
        isBroadcaster: true,
        channelId: channelId,
      ),);
    }
  }

  Future<Uint8List?> pickImage() async {
    FilePickerResult? pickedImage =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (pickedImage != null) {
      return await File(pickedImage.files.single.path!).readAsBytes();
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Uint8List? pickedImage = await pickImage();
                        if (pickedImage != null) {
                          setState(() {
                            image = pickedImage;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.0,
                          vertical: 20.0,
                        ),
                        child: image != null
                            ? SizedBox(
                                height: 300,
                                child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    strokeCap: StrokeCap.round,
                                    color: Colors.deepPurple,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(child: Image.memory(image!)),
                                    )
                                ),
                              )
                            : DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                color: Colors.deepPurple,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 10.0, left : 10, right: 10, bottom: 50),
                                    width: double.infinity,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff22292F),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Lottie.asset('assets/upload.json'),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        hintText: 'Type your title for the live video',
                        fillColor: Colors.black,
                        focusColor: Colors.deepPurple,
                        border: OutlineInputBorder(
                          borderRadius:  BorderRadius.circular(8.0),
                          borderSide:  const BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Title can't be empty";
                        } else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                  ),
                  child: ElevatedButton(
                    child: Text('Go Live!', style: latoBold,),
                    onPressed: () => goLiveStream(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
