import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String userIdKey = "USERIDKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userPicKey = "USERPICKEY";
  static const String displayNameKey = "DISPLAYNAMEKEY";
  static const String userCreatedAtKey = "USERCREATEDATKEY"; // إضافة مفتاح جديد

  // وظائف لحفظ البيانات
  static Future<bool> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, userId);
  }

  static Future<bool> saveUserEmail(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, userEmail);
  }

  static Future<bool> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, userName);
  }

  static Future<bool> saveUserPic(String userPic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userPicKey, userPic);
  }

  static Future<bool> saveDisplayName(String displayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(displayNameKey, displayName);
  }

  static Future<bool> saveUserCreatedAt(DateTime createdAt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(userCreatedAtKey, createdAt.millisecondsSinceEpoch);
  }



  // وظائف لقراءة البيانات
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<String?> getUserPic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPicKey);
  }

  static Future<String?> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displayNameKey);
  }

  static Future<DateTime?> getUserCreatedAt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? milliseconds = prefs.getInt(userCreatedAtKey);
    if (milliseconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    return null;
  }



  // وظيفة لحذف جميع البيانات
  static Future<bool> clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
