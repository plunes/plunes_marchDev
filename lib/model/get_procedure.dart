import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future<ProcedureLists> get_procedure() async {
  String url = config.Config.list_of_procedure;

  return http.get(url, headers: {"Accept": "application/json"}).then((http.Response response) {

    print("master catalogue ="+response.body);
    print("master catalogue"+response.statusCode.toString());

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    return ProcedureLists.fromJson(json.decode(response.body));
  });
}


class ProcedureLists {
  final List<SpecialityData> data;

  ProcedureLists({this.data});

  factory ProcedureLists.fromJson(List<dynamic> parsedJson) {
    List<SpecialityData> dataSpeciality = [];
    dataSpeciality = List<SpecialityData>.from(parsedJson.map((i) => SpecialityData.fromJson(i)));
    return new ProcedureLists(data: dataSpeciality);
  }
}

class SpecialityData {
  final String speciality_id;
  final String speciality;
  List<ProcedureData> procedureData = [];

  SpecialityData({this.speciality_id, this.speciality, this.procedureData});

  factory SpecialityData.fromJson(Map<String, dynamic> parsedJson) {
    return new SpecialityData(
        speciality_id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
        speciality: parsedJson['speciality'] != null ? parsedJson['speciality'] : '',
        procedureData: List<ProcedureData>.from(parsedJson['services'].map((i) => ProcedureData.fromJson(i)))


    );
  }
}

class ProcedureData {
  final String id;
  final String service;
  final String details;
  final String description;
  final String category;
  final String tags;
  final String dnd;

  ProcedureData({this.id, this.service, this.details, this.description,
    this.category, this.tags, this.dnd});

  factory ProcedureData.fromJson(Map<String, dynamic> parsedJson) {
    return new ProcedureData(
        id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
        service: parsedJson['service'] != null ? parsedJson['service'] : '',
        details: parsedJson['details'] != null ? parsedJson['details'] : '',
        description: parsedJson['dnd'] != null ? parsedJson['dnd'] : '',
        category: parsedJson['category'] != null ? parsedJson['category'] : 'Test',
        tags: parsedJson['tags'] != null ? parsedJson['tags'] : '',
        dnd: parsedJson['dnd'] != null ? parsedJson['dnd'] : '',
    );
  }
}

class SearchSolutionModel {
  final bool status;
  final String msg;
  List<ProcedureData> procedureData = [];

  SearchSolutionModel({this.status, this.msg, this.procedureData});

  factory SearchSolutionModel.fromJson(Map<String, dynamic> json) {
    return new SearchSolutionModel(
        status: json['status']!= null ? json['status']: false,
        msg: json['msg'] != null ? json['msg'] : '',
        procedureData:json['data']!=null? List<ProcedureData>.from(json['data'].map((i) => ProcedureData.fromJson(i))): List()


    );
  }
}

