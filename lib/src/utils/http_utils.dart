import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:schoolsgo_web/src/constants/constants.dart';

class HttpUtils {
  static Future post(
    String url,
    Map body,
    Function targetResponseMapper,
  ) async {
    if (shouldEncryptDataForUrl.contains(url)) {
      http.Response httpResponse = await http.post(
        Uri.parse(url),
        headers: const {"Content-type": "application/json", "encrypt": "encrypted"},
        body: base64.encode(jsonEncode(body).codeUnits),
      );
      return targetResponseMapper(json.decode(String.fromCharCodes(base64.decode(httpResponse.body.replaceAll("\"", "")))));
    } else {
      http.Response httpResponse = await http.post(
        Uri.parse(url),
        headers: const {"Content-type": "application/json"},
        body: jsonEncode(body),
      );
      return targetResponseMapper(json.decode(httpResponse.body));
    }
  }
}
