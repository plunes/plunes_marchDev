import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

Future get_prescription(String token) async {
  print(token);
  String url = config.Config.report;
  String prescriptionFileUrl = config.Config.prescriptionFileUrl;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {
    print("GetPrescription=>"+response.body);
    print("GetPrescription=>"+response.statusCode.toString());
    var error_body = {
      "success": false,
      "message": "Something went wrong!"};

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return GetPrescription.fromJson(error_body);
    }
    return GetPrescription.fromJson(json.decode(response.body));
  });
}

Future getUploadedPrescriptionFile(String token) async {
  print(token);
  String url = config.Config.prescriptionFileUrl;
  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {
    var error_body = {
      "success": false,
      "message": "Something went wrong!"};

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return GetPrescriptionFile.fromJson(error_body);
    }
    return GetPrescriptionFile.fromJson(json.decode(response.body));
  });
}

class GetPrescriptionFile {
  final bool success;
  final String message;
  List<PersonalReports> personal = [];
//  List<PersonalReports> business = [];
  GetPrescriptionFile({this.success, this.message, this.personal});

  factory GetPrescriptionFile.fromJson(Map<String, dynamic> json) {

    return GetPrescriptionFile(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
//      personal:  json['prescriptions']['personalPrescriptions']!=null? List<PersonalReports>.from(json['prescriptions']['personalPrescriptions'].map((i) => PersonalReports.fromJson(i))): List(),
      personal: json['prescriptions']['businessPrescriptions']!=null? List<PersonalReports>.from(json['prescriptions']['businessPrescriptions'].map((i) => PersonalReports.fromJson(i))): List(),
    );

  }
}



class GetPrescription {
  final bool success;
  final String message;
  List<PersonalReports> personal = [];
  List<BusinessReports> business = [];
  GetPrescription({this.success, this.message, this.personal, this.business});

  factory GetPrescription.fromJson(Map<String, dynamic> json) {

    return GetPrescription(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
      personal: List<PersonalReports>.from(json['personalReports'].map((i) => PersonalReports.fromJson(i))),
      business: List<BusinessReports>.from(json['businessReports'].map((i) => BusinessReports.fromJson(i))),
    );

  }
}



class PersonalReports {
  final String remarks;
  final String reportUrl;
  final String id;
  final int createdTime;

  final String reportName;
  final String patientMobileNumber;
  final String problemAreaDiagnosis;
  final String reasonDiagnosis;
  final String consumptionDiet;
  final String avoidDiet;
  final String precautions;
  final String medicines;
  final String test;
  final String userName;
  final String userAddress;
  final String userExperience;
  final List specialities;

  PersonalReports({this.remarks, this.reportUrl, this.id, this.reportName, this.createdTime,
  this.patientMobileNumber, this.problemAreaDiagnosis, this.reasonDiagnosis, this.consumptionDiet, this.avoidDiet,
  this.precautions, this.medicines, this.userName, this.userAddress, this.specialities, this.userExperience, this.test});

  factory PersonalReports.fromJson(Map<String, dynamic> parsedJson) {
    return new PersonalReports(
      remarks: parsedJson['remarks'] != null ? parsedJson['remarks'] : '',
      reportUrl: parsedJson['reportUrl'] != null ? parsedJson['reportUrl'] : parsedJson['prescriptionUrl'] != null ? parsedJson['prescriptionUrl'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
        reportName: parsedJson['reportName'] != null ? parsedJson['reportName'] : parsedJson['patientName'] != null ? parsedJson['patientName'] : '',
        createdTime: parsedJson['createdTime'] != null ? parsedJson['createdTime'] : 0,

      patientMobileNumber: parsedJson['patientMobileNumber'] != null ? parsedJson['patientMobileNumber'] : '',
      problemAreaDiagnosis: parsedJson['problemAreaDiagnosis'] != null ? parsedJson['problemAreaDiagnosis'] : '',
      reasonDiagnosis: parsedJson['reasonDiagnosis'] != null ? parsedJson['reasonDiagnosis'] : '',
      consumptionDiet: parsedJson['consumptionDiet'] != null ? parsedJson['consumptionDiet'] : '',
      avoidDiet: parsedJson['avoidDiet'] != null ? parsedJson['avoidDiet'] : '',
      precautions: parsedJson['precautions'] != null ? parsedJson['precautions'] : '',
      medicines: parsedJson['medicines'] != null ? parsedJson['medicines'] : '',

      userName: parsedJson['userName'] != null ? parsedJson['userName'] : '',
      userAddress: parsedJson['userAddress'] != null ? parsedJson['userAddress'] : '',
      userExperience: parsedJson['userExperience'].toString() != null ? parsedJson['userExperience'].toString() : '',
      specialities: parsedJson['userSpecialities'] != null ? parsedJson['userSpecialities'] : new List(),
      test: parsedJson['test'] != null ? parsedJson['test'] : '',
    );
  }
}


class BusinessReports {
  final String remarks;
  final String reportUrl;
  final String id;

  BusinessReports({this.remarks, this.reportUrl, this.id});

  factory BusinessReports.fromJson(Map<String, dynamic> parsedJson) {
    return new BusinessReports(
      remarks: parsedJson['remarks'] != null ? parsedJson['remarks'] : '',
      reportUrl: parsedJson['reportUrl'] != null ? parsedJson['reportUrl'] :  '',
      id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
    );
  }
}


