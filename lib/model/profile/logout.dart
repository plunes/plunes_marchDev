

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future logout_api(String user_id, String token) async {
  print(token);
  String url = config.Config.logout;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.post(url, body: json.encode({}), headers: header).then((http.Response response) {

    print("logout=>"+response.body);
    print("logout=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return LogoutPost.fromJson(error_body);
    }
    return LogoutPost.fromJson(json.decode(response.body));

  });
}

class LogoutPost {
  final bool success;
  final String message;

  LogoutPost({this.success, this.message});

  factory LogoutPost.fromJson(Map<String, dynamic> json) {

    return LogoutPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
