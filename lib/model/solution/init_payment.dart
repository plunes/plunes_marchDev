import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;


Future init_payment(var body, String token) async {
  print(token);
  String url = config.Config.booking;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.post(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("InitPayment=>"+response.body);
    print("InitPayment=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return InitPaymentPost.fromJson(error_body);
    }
    return InitPaymentPost.fromJson(json.decode(response.body));

  });
}

class InitPaymentPost {
  final bool success;
  final String message;
  final String id;
  final String status;
  final String referenceId;

  InitPaymentPost({this.success, this.message, this.id, this.referenceId, this.status});

  factory InitPaymentPost.fromJson(Map<String, dynamic> json) {

    return InitPaymentPost(
      success: json['success']!= null ? json['success']: false,
      id: json['id']!= null ? json['id']: '',
      referenceId: json['referenceId']!= null ? json['referenceId']: '',
      message: json['message']!= null ? json['message']: '',
      status: json['status']!= null ? json['status']: '',
    );

  }
}