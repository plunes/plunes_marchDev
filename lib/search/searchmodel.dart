import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/config.dart' as config;

Future<AddUtilityPost> check_utility(String url, var body, String token) async {
  var header = {
    "Accept": "application/json",
    "Authorization": "Bearer " + token
  };

  print(token);

  return http
      .post(url, body: body, headers: header)
      .then((http.Response response) {
    final int statusCode = response.statusCode;
    print("check utility" + response.body);
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    // return Post.fromJson(json.decode(response.body));
    print(response.body);

    return AddUtilityPost.fromJson(json.decode(response.body));
  });
}

Future<AddUtilityPost> add_utility(String url, var body, String token) async {
  var header = {
    "Accept": "application/json",
    "Authorization": "Bearer " + token
  };

  print(token);

  return http
      .put(url, body: body, headers: header)
      .then((http.Response response) {
    final int statusCode = response.statusCode;
    print("add utility" + response.body);
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    // return Post.fromJson(json.decode(response.body));
    print(response.body);

    return AddUtilityPost.fromJson(json.decode(response.body));
  });
}

class AddUtilityPost {
  final bool success;

  AddUtilityPost({this.success});
  factory AddUtilityPost.fromJson(Map<String, dynamic> json) {
    return AddUtilityPost(
      success: json['success'],
    );
  }
}