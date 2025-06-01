//ignore: unused_import
import 'dart:convert';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  static SharedPreferences? _sharedPreferences;

  PrefUtils() {
    // init();
    SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    print('SharedPreference Initialized');
  }

  ///will clear all the data stored in preference
  void clearPreferencesData() async {
    _sharedPreferences!.clear();
  }

Future<void> setDistance(double value) {
  return _sharedPreferences!.setDouble('distance', value);
}

double getDistance() {
  try {
    return _sharedPreferences!.getDouble('distance')!;
  } catch (e) {
    return 100.0; // Default value if not set
  }
}

  Future<void> setMute(bool value) {
    return _sharedPreferences!.setBool('mute', value);
  }

  bool getMute() {
    try {
      return _sharedPreferences!.getBool('mute')!;
    } catch (e) {
      return false; // Default value if not set
    }
  }

  Future<void> setMapTheme(String value) {
    return _sharedPreferences!.setString('mapTheme', value);
  }
  String getMapTheme() {
    try {
      return  _sharedPreferences!.getString('mapTheme')!;
    } catch (e) {
      return 'primary';
    }
  }
  Future<void> setThemeData(String value) {
    return _sharedPreferences!.setString('themeData', value);
  }

  String getThemeData() {
    try {
      return _sharedPreferences!.getString('themeData') == 'light' ? "primary" : _sharedPreferences!.getString('themeData')!;
    } catch (e) {
      return 'primary';
    }
  }
}
