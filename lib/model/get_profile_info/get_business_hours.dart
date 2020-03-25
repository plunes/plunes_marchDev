//timeSlots


import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future get_time_slots(String token, String url) async {
  print(token);


  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {
    print("GettimeSlots=>"+response.body);
    print("GettimeSlots=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return GettimeSlots.fromJson(error_body);
    }
    return GettimeSlots.fromJson(json.decode(response.body));

  });
}

class GettimeSlots {
  final bool success;
  final String message;
  List<FieldsData> fields = [];

  GettimeSlots({this.success, this.message, this.fields});

  factory GettimeSlots.fromJson(Map<String, dynamic> json) {

    return GettimeSlots(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
      fields: List<FieldsData>.from(json['field'].map((i) =>
          FieldsData.fromJson(i))),
    );

  }
}

class FieldsData {
  final List slots;
  final String day;
  final String closed;

  FieldsData({this.slots, this.day, this.closed});

  factory FieldsData.fromJson(Map<String, dynamic> parsedJson) {
    return new FieldsData(
      slots: parsedJson['slots'] != null ? parsedJson['slots'] : '',
      day: parsedJson['day'] != null ? parsedJson['day'] : '',
      closed: parsedJson['closed'] != null ? parsedJson['closed'].toString() : '',
    );
  }
}
