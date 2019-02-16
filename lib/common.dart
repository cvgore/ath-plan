import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home/screen.dart' show consentAgreed;

SharedPreferences _prefs;

Directory _appDir;
Directory _cacheDir;
bool _debugMode = false;

void _getSharedPrefsInstance() async {
  if (_prefs == null) {
    var p = await SharedPreferences.getInstance();
    _prefs = p;
  }
}

bool get g_inDebugMode {
  assert(_debugMode = true);
  return _debugMode;
}

bool get g_consentAgreed {
  return _prefs?.getBool('gdpr-consent');
}

bool get g_isSurprise {
  return _prefs?.getBool('is-surprise');
}

String getPaddedZero(int day) {
  return day.toString().padLeft(2, '0');
}

String truncateIfExceeds(String str, int maxLen) {
  return str.length <= maxLen ? str : '${str.substring(0, maxLen - 3)}...';
}

Future<File> getFileFromCache(String fileName) async {
  if (_appDir == null) {
    _appDir = await getApplicationDocumentsDirectory();
  }
  if (! await _appDir.exists()) {
    await _appDir.create();
  }
  if (_cacheDir == null) {
    _cacheDir = Directory("${_appDir.path}/cache");
  }
  if (! await _cacheDir.exists()) {
    await _cacheDir.create();
  }
  var _timetablesDir = Directory("${_appDir.path}/cache/timetables");
  if (! await _timetablesDir.exists()) {
    await _timetablesDir.create();
  }
  var file = File("${_appDir.path}/$fileName");
  if (! await file.exists()) {
    await file.create();
  }
  return file;
}

class FilePaths {
  static const String GROUPS_CACHE = "cache/groups.json";
  static String timetableCache(int timetableId) {
    return "cache/timetables/plan-$timetableId.json";
  }
  static const String OWN_GROUPS = "my_groups.json";
  static const String INDEX_CACHE = "cache/index.json";
}

class FileCache {
  static final Map<String, File> _cache = Map();

  static Future<File> getFile(String fullPathToFile) async {
    if (_cache.containsKey(fullPathToFile)) {
      return _cache[fullPathToFile];
    } else {
      return _cache[fullPathToFile] = await getFileFromCache(fullPathToFile);
    }
  }

  static Future<void> dropCache() async {
    if (_cacheDir != null && await _cacheDir.exists()) {
      _cacheDir.delete(recursive: true);
    }
    _cache.clear();
  }

}