import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';



Future<SendOtpPost> sendotp(String url) async {

  return http.post(url, headers: {"Accept": "application/json"}).then((http.Response response) {

    print("send otp"+response.body);
    print("send otp"+response.statusCode.toString());


    var error_body = {
      "type":"Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return SendOtpPost.fromJson(error_body);
    }
    return SendOtpPost.fromJson(json.decode(response.body));
  });
}

class SendOtpPost {
  final String type;
  SendOtpPost({this.type});

  factory SendOtpPost.fromJson(Map<String, dynamic> json) {

    return SendOtpPost(
      type: json['type'] != null ? json['type']: json['type'],
    );

  }
}