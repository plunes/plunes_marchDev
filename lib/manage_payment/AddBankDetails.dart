import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/model/get_profile_info/get_bank_details.dart';
import 'package:plunes/model/profile/manage_payment/bank_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plunes/config.dart' as config;
import '../config.dart';

class AddBankDetails extends StatefulWidget {
  static const tag = '/addbankdetails';

  @override
  _AddBankDetailsState createState() => _AddBankDetailsState();
}

class _AddBankDetailsState extends State<AddBankDetails> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  bool name_valid = true;
  bool account_num_valid = true;
  bool ifsc_code_valid = true;
  bool pan_num_valid = true;
  bool account_holder_name_valid = true;

  TextEditingController bank_name_ = new TextEditingController();
  TextEditingController account_number_ = new TextEditingController();
  TextEditingController ifsc_code_ = new TextEditingController();
  TextEditingController pan_number_ = new TextEditingController();
  TextEditingController account_holder_name_ = new TextEditingController();

  String user_token = "";
  String user_id = "";
  bool progress = true;

  void proceed_data() async {

    setState(() {
      progress = true;
    });


    var bank_info = {
      "name": account_holder_name_.text,
      "bankName": bank_name_.text,
      "ifscCode": ifsc_code_.text,
      "accountNumber": account_number_.text,
      "panNumber": pan_number_.text
    };

    var body = {
      "bankDetails": bank_info
    };

    BankDetailsPost allNotificationsPost = await bank_details(body,user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error);
      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;

      if (allNotificationsPost.success) {

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (
              BuildContext context,
              ) =>
              _popup_saved(context),
        );

      } else {
        config.Config.showInSnackBar(
            _scaffoldKey, allNotificationsPost.message, Colors.red);
      }

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    setState(() {
      user_token = token;
      user_id = uid;
    });

    get_bank_detail();
  }

  get_bank_detail() async {
    GetBankDetails getBankDetails = await get_bank_details(user_id,user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error);
      setState(() {
        progress = false;
      });
    });



    setState(() {
      progress = false;

      if (getBankDetails.success) {

        bank_name_.text = getBankDetails.bankName;
        account_number_.text = getBankDetails.accountNumber;
        ifsc_code_.text = getBankDetails.ifscCode;
        pan_number_.text = getBankDetails.panNumber;
        account_holder_name_.text = getBankDetails.name;

      } else {
        config.Config.showInSnackBar(
            _scaffoldKey, getBankDetails.message, Colors.red);
      }

    });

    setState(() {
      progress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text(
        "Bank Details",
        style: TextStyle(color: Colors.black),
      ),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );

    final bank_name = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {
            if (val == '') {
              name_valid = false;
            } else {
              name_valid = true;
            }
          });
        },
        controller: bank_name_,
        decoration: InputDecoration(
            labelText: 'Bank Name',
            errorText: name_valid ? null : "Please enter your bank name"),
      ),
    );

    final account_number = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {
            if (val == '' && !config.Config.isNumeric(val)) {
              account_num_valid = false;
            } else {
              account_num_valid = true;
            }
          });
        },
        controller: account_number_,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            labelText: 'Account Number',
            errorText:
                account_num_valid ? null : "Please enter your Account Number"),
      ),
    );

    final IFSC_code = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {
            if (val == '') {
              ifsc_code_valid = false;
            } else {
              ifsc_code_valid = true;
            }
          });
        },
        controller: ifsc_code_,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
            labelText: 'IFSC Code',
            errorText: ifsc_code_valid ? null : "Please enter your IFSC Code"),
      ),
    );

    final pan_number = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {

            String regexp = r'^([A-Z]){5}([0-9]){4}([A-Z]){1}?$';

            if (val == '' || !RegExp(regexp).hasMatch(val)) {
              pan_num_valid = false;
            } else {
              pan_num_valid = true;
            }

          });
        },
        controller: pan_number_,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
            labelText: 'Pan Number',
            errorText: pan_num_valid ? null : "Please enter your Pan Number"),
      ),
    );

    final Account_holder_name = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {
            if (val == '') {
              account_holder_name_valid = false;
            } else {
              account_holder_name_valid = true;
            }
          });
        },
        controller: account_holder_name_,
        decoration: InputDecoration(
            labelText: "Account Holder\'s Name",
            errorText: account_holder_name_valid
                ? null
                : "Please enter Account Holder\'s Name"),
      ),
    );

    final proceed = Padding(
      padding:
          const EdgeInsets.only(left: 36.0, right: 36.0, bottom: 30, top: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: InkWell(
          onTap: (){

            if(name_valid &&
                account_num_valid &&
                ifsc_code_valid &&
                pan_num_valid &&
                account_holder_name_valid &&
                bank_name_.text != '' &&
                account_number_.text != '' &&
                ifsc_code_.text != '' &&
                pan_number_.text != '' &&
                account_holder_name_.text != ''){
              proceed_data();
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),

                color:name_valid &&
                    account_num_valid &&
                    ifsc_code_valid &&
                    pan_num_valid &&
                    account_holder_name_valid &&
                    bank_name_.text != '' &&
                    account_number_.text != '' &&
                    ifsc_code_.text != '' &&
                    pan_number_.text != '' &&
                    account_holder_name_.text != ''? Color(0xff01d35a): Colors.grey),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Proceed', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );

    final form = Container(
      child: ListView(
        children: <Widget>[
          bank_name,
          SizedBox(
            height: 10,
          ),
          account_number,
          SizedBox(
            height: 10,
          ),
          IFSC_code,
          SizedBox(
            height: 10,
          ),
          pan_number,
          SizedBox(
            height: 10,
          ),
          Account_holder_name,
          SizedBox(
            height: 20,
          ),
         progress? SpinKitThreeBounce(
           color: Color(0xff01d35a),
           size: 30.0,
         ): proceed
        ],
      ),
    );

    return Scaffold(appBar: app_bar, key: _scaffoldKey, backgroundColor: Colors.white, body: form);
  }

  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Saved..'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: new Text(
            'OK',
            style: TextStyle(color: Color(0xff01d35a)),
          ),
        ),
      ],
    );
  }

}
