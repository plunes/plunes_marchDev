import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future achievments_delete(String achievments_id, String token) async {
  print(token);
  String url = config.Config.user+"/achievements/"+achievments_id;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.delete(url, headers: header).then((http.Response response) {

    print("AchievmentsDelete=>"+response.body);
    print("AchievmentsDelete=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return AchievmentsDelete.fromJson(error_body);
    }
    return AchievmentsDelete.fromJson(json.decode(response.body));

  });
}

class AchievmentsDelete {
  final bool success;
  final String message;

  AchievmentsDelete({this.success, this.message});

  factory AchievmentsDelete.fromJson(Map<String, dynamic> json) {

    return AchievmentsDelete(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
