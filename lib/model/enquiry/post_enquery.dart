

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future post_enquery(var body, String token) async {
  print(token);
  String url = config.Config.enquiry;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.post(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("PostEnqueryPost=>"+response.body);
    print("PostEnqueryPost=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return PostEnqueryPost.fromJson(error_body);
    }
    return PostEnqueryPost.fromJson(json.decode(response.body));

  });
}

class PostEnqueryPost {
  final bool success;
  final String message;

  PostEnqueryPost({this.success, this.message});

  factory PostEnqueryPost.fromJson(Map<String, dynamic> json) {

    return PostEnqueryPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
