import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;

Future get_bank_details(String user_id, String token) async {
  print(token);
  String url = config.Config.user+"/"+user_id+"/bankDetails";

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {
    print("GetBankDetails=>"+response.body);
    print("GetBankDetails=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return GetBankDetails.fromJson(error_body);
    }
    return GetBankDetails.fromJson(json.decode(response.body));

  });
}

class GetBankDetails {
  final bool success;
  final String message;

  final String name;
  final String bankName;
  final String ifscCode;
  final String accountNumber;
  final String panNumber;


  GetBankDetails({this.success, this.message, this.name, this.bankName,
    this.ifscCode, this.accountNumber, this.panNumber});

  factory GetBankDetails.fromJson(Map<String, dynamic> json) {

    return GetBankDetails(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',

      name: json['field']['name']!= null ? json['field']['name']: '',
      bankName: json['field']['bankName']!= null ? json['field']['bankName']: '',
      ifscCode: json['field']['ifscCode']!= null ? json['field']['ifscCode']: '',
      accountNumber: json['field']['accountNumber']!= null ? json['field']['accountNumber']: '',
      panNumber: json['field']['panNumber']!= null ? json['field']['panNumber']: '',
    );

  }
}
