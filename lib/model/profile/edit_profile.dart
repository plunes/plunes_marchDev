import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plunes/config.dart' as config;


Future edit_profile(var body, String token) async {

  String url = config.Config.user;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.put(url, body: json.encode(body), headers: header).then((http.Response response) {

    print("edit profile=>"+response.body);
    print("edit profile=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return EditProfilePost.fromJson(error_body);
    }
    return EditProfilePost.fromJson(json.decode(response.body));
  });
}

class EditProfilePost {

  final bool success;
  final String message;
  Data user;

  EditProfilePost({this.success, this.message, this.user});

  factory EditProfilePost.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('user')){

      return EditProfilePost(
        success: json['success']!= null ? json['success']: false,
        user: Data.fromJson(json['user']!= null ? json['user']: ''),
        message: json['message']!= null ? json['message']: '',
      );
    }else{
      return EditProfilePost(
          success: json['success']!= null ? json['success']: false,
          message: json['message']!= null ? json['message']: '',
      );
    }
  }
}


class Data{
  String token;
  String email;

  String name;
  String phone_number;

  String user_type;
  int phone_number_verified;
  String uid;


  Data({ this.token, this.email, this.name,this.phone_number, this.user_type,
    this.phone_number_verified , this.uid});

  factory Data.fromJson(Map<String, dynamic> json) {

    print(json['activated'].toString());

    return Data(
        token: json['token'],
        email: json['email'],
        name: json['name'],
        phone_number: json['phone_number'],
        user_type: json['user_type'],
        phone_number_verified: json['phone_number_verified'],
        uid :json['_id']

    );
  }
}