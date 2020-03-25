import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plunes/config.dart' as config;


Future<SendPrescriptionModel> sendPrescriptionAPI(var body, String token) async {
  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };
  return http.post(config.Config.prescription, body: json.encode(body), headers: header).then((http.Response response) {
    print("sendPrescriptionAPI=>"+response.body);
    print("sendPrescriptionAPI=>"+response.statusCode.toString());
    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };
    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return SendPrescriptionModel.fromJson(error_body);
    }
    return SendPrescriptionModel.fromJson(json.decode(response.body));

  });
}

class SendPrescriptionModel {
  final bool success;
  final String message;

  SendPrescriptionModel({this.success, this.message});

  factory SendPrescriptionModel.fromJson(Map<String, dynamic> json) {

    return SendPrescriptionModel(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
