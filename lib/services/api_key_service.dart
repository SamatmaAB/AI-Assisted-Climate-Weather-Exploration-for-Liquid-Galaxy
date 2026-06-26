import 'package:flutter/services.dart';

class ApiKeyService {
  static const MethodChannel _channel =
  MethodChannel('gemini');

  static Future<String> getApiKey() async {
    return await _channel.invokeMethod<String>(
      'getApiKey',
    ) ??
        '';
  }
}