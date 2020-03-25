import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plunes/config.dart' as config;


Future send_prescription(var body, String token) async {
  print(token);
  String url = config.Config.report;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.post(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("SendPrescription=>"+response.body);
    print("SendPrescription=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return SendPrescription.fromJson(error_body);
    }
    return SendPrescription.fromJson(json.decode(response.body));

  });
}

Future deleteReport(String idReport, String token) async {
  String url = config.Config.report + '/'+idReport;
  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };
  return http.delete(url, headers: header).then((http.Response response) {
    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };
    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return SendPrescription.fromJson(error_body);
    }
    return SendPrescription.fromJson(json.decode(response.body));

  });
}

class SendPrescription {
  final bool success;
  final String message;

  SendPrescription({this.success, this.message});

  factory SendPrescription.fromJson(Map<String, dynamic> json) {

    return SendPrescription(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
