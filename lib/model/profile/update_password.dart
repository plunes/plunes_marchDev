import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plunes/config.dart' as config;


Future<PostPassword> update_password(var body) async {

  String url = config.Config.update_password;

  return http.put(url, body: json.encode(body), headers: {"Content-Type": "application/json"}).then((http.Response response) {

    print("update Password=>"+response.body);
    print("update Password=>"+response.statusCode.toString());

    var body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return PostPassword.fromJson(body);
    }
    return PostPassword.fromJson(json.decode(response.body));
  });

}

class PostPassword {
  final bool success;
  final String message;
  PostPassword({this.success, this.message});

  factory PostPassword.fromJson(Map<String, dynamic> json) {
    return PostPassword(
      success: json['success'] != null ? json['success'] : false,
        message: json['message']!=null ? json['message']: ''
    );

  }

}