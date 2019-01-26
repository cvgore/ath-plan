import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

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

class _GlobalWebClient extends http.BaseClient {
  final http.Client _inner;

  _GlobalWebClient(): _inner = http.Client();

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request = _TimeoutableRequest(request.method,  Uri.parse('https://plany.ath.bielsko.pl/${request.url.toString()}'));
    request.headers['user-agent'] = 'ATH-Plan';
    return _inner.send(request);
  }
}

class _TimeoutableRequest extends http.BaseRequest {
  final String method;
  final Uri url;
  final Duration timeout = Duration(seconds: 5);

  _TimeoutableRequest(this.method, this.url): super(method, url);

  Future<http.StreamedResponse> send() async {
    var timer = Timer(timeout, onTimeout);
    var response = super.send();
    response.then((value) {
      timer.cancel();
      return value;
    });
    return response;
  }

  void onTimeout() {
    throw new HttpRequestTimeoutError(url);
  }
}

class HttpRequestTimeoutError extends HttpException {
  final Uri uri;
  HttpRequestTimeoutError(this.uri): super('Request timeout', uri: uri);
}

class WebRequest {
  static Future<http.Response> get(dynamic url) =>
    _withClient((client) => client.get(url));
  static Future<http.Response> post(dynamic url, { dynamic body, Encoding encoding }) =>
    _withClient((client) => client.post(url, body: body, encoding: encoding));

  static Future<T> _withClient<T>(Future<T> fn(_GlobalWebClient client)) async {
    var client = new _GlobalWebClient();
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }
}

