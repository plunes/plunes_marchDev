import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future reschedule_appointment(var body, String booking_id, String token) async {
  String url = config.Config.booking+"/"+booking_id+"/reschedule";

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.put(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("RescheduleAppointment=>"+response.body);
    print("RescheduleAppointment=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return RescheduleAppointment.fromJson(error_body);
    }
    return RescheduleAppointment.fromJson(json.decode(response.body));

  });
}

class RescheduleAppointment {
  final bool success;
  final String message;

  RescheduleAppointment({this.success, this.message});

  factory RescheduleAppointment.fromJson(Map<String, dynamic> json) {

    return RescheduleAppointment(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
