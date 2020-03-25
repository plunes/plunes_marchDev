import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future invoice_appointment(String booking_id, String token) async {

  String url = config.Config.booking+"/invoice/"+booking_id;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {

    print("InvoiceAppointment=>"+response.body);
    print("InvoiceAppointment=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return InvoiceAppointment.fromJson(error_body);
    }
    return InvoiceAppointment.fromJson(json.decode(response.body));

  });
}

class InvoiceAppointment {
  final bool success;
  final String message;

  InvoiceAppointment({this.success, this.message});

  factory InvoiceAppointment.fromJson(Map<String, dynamic> json) {

    return InvoiceAppointment(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
    );

  }
}
