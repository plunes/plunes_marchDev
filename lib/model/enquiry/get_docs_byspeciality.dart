

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future<GetDoctors_specialisty> get_docs_byspeciality(String speciality_id, String token) async {

  print(token);

  String url = config.Config.user+"?specialityId="+speciality_id;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {

    print("GetDoctors_specialisty=>"+response.body);
    print("GetDoctors_specialisty=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return GetDoctors_specialisty.fromJson(error_body);
    }
    return GetDoctors_specialisty.fromJson(json.decode(response.body));

  });
}

class GetDoctors_specialisty {
  final bool success;
  final String message;
  List<PostsData> posts = [];

  GetDoctors_specialisty({this.success, this.message, this.posts});

  factory GetDoctors_specialisty.fromJson(Map<String, dynamic> json) {

    return GetDoctors_specialisty(
      success: json['success']!= null ? json['success']: false,

      posts: List<PostsData>.from(json['users'].map((i) =>
          PostsData.fromJson(i))),

      message: json['message']!= null ? json['message']: '',
    );
  }
}


class PostsData {
  final String name;
  final String imageUrl;
  final String id;
  final String address;
  PostsData({this.name, this.imageUrl, this.id, this.address});

  factory PostsData.fromJson(Map<String, dynamic> parsedJson) {
    return new PostsData(
      name: parsedJson['name'] != null ? parsedJson['name'] : '',
      imageUrl: parsedJson['imageUrl'] != null ? parsedJson['imageUrl'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'].toString() : '',
      address: parsedJson['address'] != null ? parsedJson['address'].toString() : '',
    );
  }
}
