import 'package:messenger/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "DISPLAYNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfilePicKey = "USERPROFILEPICKEY";

  //save user info to storage
  Future<bool> saveUserID(String? getuserID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString((userIdKey), getuserID!);
  }

  Future<bool> saveUserName(String? getuserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString((userNameKey), getuserName!);
  }

  Future<bool> saveDisplayName(String? getDisplayName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString((displayNameKey), getDisplayName!);
  }

  Future<bool> saveUserEmail(String? getuserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString((userEmailKey), getuserEmail!);
  }

  Future<bool> saveUserProfile(String? getuserProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString((userProfilePicKey), getuserProfile!);
  }

  //get user info from storage

  Future<String?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  Future<String?> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(displayNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  Future<String?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userProfilePicKey);
  }
}
