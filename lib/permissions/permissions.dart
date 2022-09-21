import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class Permissions {
  static Future<bool> cameraAndMicrophonePermissionsGranted() async {
    PermissionStatus cameraPermissionStatus = (await _getCameraPermission()) as PermissionStatus;
    PermissionStatus? microphonePermissionStatus = (await _getMicrophonePermission()) as PermissionStatus?;

    Future<void> handleCameraAndMic(Permission permission) async {
      await permission.request();
    }

    if (cameraPermissionStatus == PermissionStatus.granted &&
        microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      await handleCameraAndMic(Permission.camera);
      await handleCameraAndMic(Permission.microphone);
      _handleInvalidPermissions(
          cameraPermissionStatus, microphonePermissionStatus!);
      return false;
    }
  }


  static Future<Object> _getCameraPermission() async {
    PermissionStatus permission = await Permission.camera.status;
    if (permission == PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      PermissionStatus permissionStatus = await Permission.camera.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  static Future<Object> _getMicrophonePermission() async {
    PermissionStatus permission = await Permission.microphone.status;
    if (permission == PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      PermissionStatus permissionStatus = await Permission.microphone.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  static void _handleInvalidPermissions(
      PermissionStatus cameraPermissionStatus,
      PermissionStatus microphonePermissionStatus,
      ) {
    if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to camera and microphone denied",
          details: null);
    } else if (cameraPermissionStatus == PermissionStatus.denied &&
        microphonePermissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

}
