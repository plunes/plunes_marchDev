

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future send_replay_api(var body, String token) async {

  print(token);
  String url = config.Config.enquiry;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.put(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("SendReplayPost=>"+response.body);
    print("SendReplayPost=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return SendReplayPost.fromJson(error_body);
    }
    return SendReplayPost.fromJson(json.decode(response.body));

  });
}

class SendReplayPost {
  final bool success;
  final String message;

  SendReplayPost({this.success, this.message});

  factory SendReplayPost.fromJson(Map<String, dynamic> json) {

    return SendReplayPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: 'Something went wrong!',
    );

  }
}
