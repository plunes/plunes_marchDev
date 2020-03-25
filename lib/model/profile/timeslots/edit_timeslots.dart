import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';



Future set_time_slots(var body, String token) async {

  String url = config.Config.user;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.put(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("set time slots"+response.statusCode.toString());
    print("set time slots"+response.body);

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return TimeSlotsPost.fromJson(error_body);
    }
    return TimeSlotsPost.fromJson(json.decode(response.body));
  });
}

class TimeSlotsPost {
  final bool success;
  final String message;
  TimeSlotsPost({this.success, this.message});

  factory TimeSlotsPost.fromJson(Map<String, dynamic> json) {
    return TimeSlotsPost(
        success: json['success'] != null ? json['success']: false,
        message: json['message'] != null ? json['message']:''
    );
  }
}




