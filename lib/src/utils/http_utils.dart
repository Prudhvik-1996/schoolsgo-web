import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schoolsgo_web/src/constants/constants.dart';

class HttpUtils {
  static Future post(
    String url,
    Map body,
    Function targetResponseMapper,
  ) async {
    if (shouldEncryptDataForUrl.contains(url)) {
      debugPrint("Encrypting data");
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

  static Future get(
    String url,
    Function targetResponseMapper,
  ) async {
    if (shouldEncryptDataForUrl.contains(url)) {
      debugPrint("Encrypting data");
      http.Response httpResponse = await http.get(
        Uri.parse(url),
        headers: const {"Content-type": "application/json", "encrypt": "encrypted"},
      );
      return targetResponseMapper(json.decode(String.fromCharCodes(base64.decode(httpResponse.body.replaceAll("\"", "")))));
    } else {
      http.Response httpResponse = await http.get(
        Uri.parse(url),
        headers: const {"Content-type": "application/json"},
      );
      return targetResponseMapper(json.decode(httpResponse.body));
    }
  }

  static Future<List<int>> postToDownloadFile(
    String url,
    Map body,
  ) async {
    var headers = {'Content-Type': 'application/json'};
    var timeout = const Duration(days: 1);
    var client = http.Client();
    var request = http.Request('POST', Uri.parse(url));
    request.headers.addAll(headers);
    request.body = jsonEncode(body);
    var streamedResponse = await client.send(request).timeout(timeout);
    return streamedResponse.stream.first;
  }

  // New method to get the receipt number
  static Future<int> getNewReceiptNumber(int schoolId) async {
    final url = 'https://epsiloninfinityservices.com:8000/schoolsgo/fee/getNewReceiptNumber?schoolId=$schoolId';
    return await get(url, (data) => data as int);
  }

  // New method to get the voucher number
  static Future<int> getNewVoucherNumber(int schoolId) async {
    final url = 'https://epsiloninfinityservices.com:8000/schoolsgo/ledger/getNewVoucherNumber?schoolId=$schoolId';
    return await get(url, (data) => data as int);
  }
}
