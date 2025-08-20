import 'package:cooler_alerts/cooler_alerts.dart';
import 'package:flutter/material.dart';
import '../../constants/color.dart';

Future kCoolAlert({
  required String message,
  required BuildContext context,
  required CoolAlertType alert,
  void Function(BuildContext)? action,
  barrierDismissible = true,
  confirmBtnText = 'Ok',
}) {
  return CoolerAlerts.show(
      backgroundColor: primaryColor,
      context: context,
      type: alert,
      text: message,
      onConfirmBtnTap: action,
      barrierDismissible: barrierDismissible,
      confirmBtnText: confirmBtnText);
}
