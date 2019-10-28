
import 'package:shared_preferences/shared_preferences.dart';

class Utils{
  static SharedPreferences preferences;
  static Future<bool> getInstance() async{
    preferences = await SharedPreferences.getInstance();
    return true;
  }
}