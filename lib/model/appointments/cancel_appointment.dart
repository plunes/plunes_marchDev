import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future cancel_appointment(String booking_id, String token) async {

  String url = config.Config.booking+"/"+booking_id+"/cancel";

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.put(url, headers: header).then((http.Response response) {

    print("CancelAppointment=>"+response.body);
    print("CancelAppointment=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return CancelAppointment.fromJson(error_body);
    }
    return CancelAppointment.fromJson(json.decode(response.body));

  });
}

class CancelAppointment {
  final bool success;
  final String message;

  CancelAppointment({this.success, this.message});

  factory CancelAppointment.fromJson(Map<String, dynamic> json) {

    return CancelAppointment(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
