import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future<dynamic> edit_catalogue(var body, String token) async {

  String url = config.Config.user;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.put(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("update catalogue=>"+response.body);
    print("update catalogue=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return EditCataloguePost.fromJson(error_body);
    }
    return EditCataloguePost.fromJson(json.decode(response.body));

  });
}

class EditCataloguePost{
  final bool success;
  final String message;
  EditCataloguePost({this.success, this.message});

  factory EditCataloguePost.fromJson(Map<String, dynamic> json) {
    return EditCataloguePost(
      success: json['success'] !=null ? json['success']: false,
      message: json['message'] !=null ? json['message']: 'Something went wrong!',
    );
  }
}

