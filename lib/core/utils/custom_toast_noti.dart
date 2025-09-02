import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class CustomToastNoti {
  static void show({
    required BuildContext context,
    required String title,
    required String description,
    ToastificationType type = ToastificationType.success,
    Duration duration = const Duration(seconds: 5),
  }) {
    Color primaryColor;
    IconData iconData;

    switch (type) {
      case ToastificationType.info:
        primaryColor = Colors.blue;
        iconData = Icons.info_outline;
        break;
      case ToastificationType.warning:
        primaryColor = Colors.amber;
        iconData = Icons.warning_amber_rounded;
        break;
      case ToastificationType.error:
        primaryColor = Colors.red;
        iconData = Icons.error_outline;
        break;
      case ToastificationType.success:
      default:
        primaryColor = Colors.green;
        iconData = Icons.check_circle_outline;
        break;
    }

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: duration,
      title: Text(title),
      description: Text(description),
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      icon: Icon(iconData),
      primaryColor: primaryColor,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      dragToClose: true,
    );
  }
}
