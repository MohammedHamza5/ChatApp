import 'package:flutter/material.dart';

class AppNavigation{
  // الانتقال إلى شاشة جديدة
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // الانتقال إلى شاشة جديدة واستبدال الشاشة الحالية
  static void navigateAndReplace(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // الانتقال إلى شاشة جديدة وإزالة جميع الشاشات السابقة
  static void navigateAndRemoveUntil(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
          (Route<dynamic> route) => false,
    );
  }

  // العودة إلى الشاشة السابقة
  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  // العودة إلى الشاشة السابقة مع تمرير البيانات
  static void navigateBackWithResult(BuildContext context, dynamic result) {
    Navigator.pop(context, result);
  }
}
