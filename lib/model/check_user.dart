import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

import 'profile/user_profile.dart';



Future check_user(String mobile_number) async {
  String url = config.Config.user + '?mobileNumber='+mobile_number;

  return http.get(url, headers: {"Accept": "application/json"}).then((http.Response response) {
    print("check user"+response.statusCode.toString());
    print("check user"+response.body);
    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null)
      return CheckPost.fromJson(error_body);

    return CheckPost.fromJson(json.decode(response.body));
  });
}

class CheckPost {
  final bool success;
  final String message;
  User user;
  CheckPost({this.success, this.message,  this.user});

  factory CheckPost.fromJson(Map<String, dynamic> json) {
    return CheckPost(
      success: json['success'] != null ? json['success']: false,
      message: json['message'] != null ? json['message']:'',
        user: json['user']!=null? User.fromJson(json['user']): new User());
  }
}