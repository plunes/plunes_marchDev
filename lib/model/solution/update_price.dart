import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future update_price(var body, String token) async {
  print(token);
  String url = config.Config.find_solution;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.put(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("UpdatePrice=>"+response.body);
    print("UpdatePrice=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return UpdatePrice.fromJson(error_body);
    }
    return UpdatePrice.fromJson(json.decode(response.body));

  });
}

class UpdatePrice {
  final bool success;
  final String message;

  UpdatePrice({this.success, this.message});

  factory UpdatePrice.fromJson(Map<String, dynamic> json) {

    return UpdatePrice(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
