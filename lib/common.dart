import 'screens/home/screen.dart' show consentAgreed;

bool get g_inDebugMode {
  bool debugMode = false;

  assert(debugMode = true);

  return debugMode;
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
