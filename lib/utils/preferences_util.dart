import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtil {
  static late final SharedPreferences preferences;

  static initInstance() async {
    preferences = await SharedPreferences.getInstance();
  }
}
