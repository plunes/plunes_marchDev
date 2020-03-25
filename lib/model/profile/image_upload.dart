import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;


Future image_upload(var body, String token) async {
  print(token);
  String url = config.Config.image_upload;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.post(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("ImgUploadPost=>"+response.body);
    print("ImgUploadPost=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return ImgUploadPost.fromJson(error_body);
    }
    return ImgUploadPost.fromJson(json.decode(response.body));

  });
}

class ImgUploadPost {
  final bool success;
  final String message;
  final String url;

  ImgUploadPost({this.success, this.message, this.url});

  factory ImgUploadPost.fromJson(Map<String, dynamic> json) {

    return ImgUploadPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
      url: json['url']!= null ? json['url']: '',
    );
  }
}
