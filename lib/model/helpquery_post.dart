import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future help_post(var body, String token) async {

  String url = config.Config.help_post;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.post(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("HelpPost=>"+response.body);
    print("HelpPost=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return HelpPost.fromJson(error_body);
    }
    return HelpPost.fromJson(json.decode(response.body));

  });
}

class HelpPost {
  final bool success;
  final String message;

  HelpPost({this.success, this.message});

  factory HelpPost.fromJson(Map<String, dynamic> json) {

    return HelpPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
