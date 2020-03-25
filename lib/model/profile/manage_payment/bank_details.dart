import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;

Future bank_details(var body, String token) async {
  print(token);
  String url = config.Config.user;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.put(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("BankDetailsPost=>"+response.body);
    print("BankDetailsPost=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return BankDetailsPost.fromJson(error_body);
    }
    return BankDetailsPost.fromJson(json.decode(response.body));

  });
}

class BankDetailsPost {
  final bool success;
  final String message;

  BankDetailsPost({this.success, this.message});

  factory BankDetailsPost.fromJson(Map<String, dynamic> json) {

    return BankDetailsPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}


