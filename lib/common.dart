import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'screens/home/screen.dart' show consentAgreed;

Directory _appDir;
Directory _cacheDir;
bool _debugMode = false;

bool get g_inDebugMode {
  assert(_debugMode = true);
  return _debugMode;
}

bool get g_consentAgreed {
  return consentAgreed;
}

String getPaddedZero(int day) {
  return day.toString().padLeft(2, '0');
}

String truncateIfExceeds(String str, int maxLen) {
  return str.length <= maxLen ? str : '${str.substring(0, maxLen - 3)}...';
}

Future<File> getFileFromCache(String fileName, [bool errorIfNotFound = true]) async {
  if (_appDir == null) {
    _appDir = await getApplicationDocumentsDirectory();
  }
  if (_cacheDir == null) {
    _cacheDir = Directory(_appDir.path + "/cache");
  }
  if (! await _cacheDir.exists()) {
    await _cacheDir.create();
  }
  var file = File(_cacheDir.path + "/$fileName");
  if (errorIfNotFound && ! await file.exists()) {
    return throw FileSystemException("File not found", file.path);
  }
  return file;
}
