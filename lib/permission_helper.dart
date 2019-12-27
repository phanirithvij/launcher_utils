import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PermissionStatusX { granted, notGranted, doNotAskAgain }

// https://github.com/Baseflow/flutter-permission-handler/issues/96#issuecomment-526617086
class PermissionHelper {
  static Future<PermissionStatusX> requestPermissions(
      TargetPlatform platform, PermissionGroup permissionGroup) async {
    PermissionStatusX status;
    if (platform == TargetPlatform.android) {
      Map<PermissionGroup, PermissionStatus> permissionsGranted =
          await PermissionHandler()
              .requestPermissions(<PermissionGroup>[permissionGroup]);
      PermissionStatus permissionStatus = permissionsGranted[permissionGroup];

      if (permissionStatus == PermissionStatus.granted) {
        status = PermissionStatusX.granted;
      } else {
        bool beenAsked = await hasPermissionBeenAsked(permissionGroup);
        bool rationale = await PermissionHandler()
            .shouldShowRequestPermissionRationale(permissionGroup);
        if (beenAsked && !rationale) {
          status = PermissionStatusX.doNotAskAgain;
        } else {
          status = PermissionStatusX.notGranted;
        }
      }
    } else {
      status = PermissionStatusX.granted;
    }

    setPermissionHasBeenAsked(permissionGroup);
    return status;
  }

  static Future<void> setPermissionHasBeenAsked(
      PermissionGroup permissionGroup) async {
    (await SharedPreferences.getInstance())
        .setBool('PERMISSION_ASKED_${permissionGroup.value}', true);
  }

  static Future<bool> hasPermissionBeenAsked(
      PermissionGroup permissionGroup) async {
    return (await SharedPreferences.getInstance())
            .getBool('PERMISSION_ASKED_${permissionGroup.value}') ??
        false;
  }
}
