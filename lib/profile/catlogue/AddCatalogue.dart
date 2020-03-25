import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/model/profile/catalogue/edit_catalogue.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';
import 'package:plunes/config.dart' as config;


class ChooseSpeciality extends StatefulWidget {
  static const tag = '/choose_speciality';


  final List<ProcedureData> service;

  ChooseSpeciality({Key key, this.service}) : super(key: key);


  @override
  _ChooseSpecialityState createState() => _ChooseSpecialityState(service);
}

class _ChooseSpecialityState extends State<ChooseSpeciality> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<ProcedureData> service = new List();
  _ChooseSpecialityState( this.service);

  String user_token="";
  bool call = false;
  /// specialities lists
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _speciality="";
  /// varience lists
  List<DropdownMenuItem<String>> _dropDownMenuItems2;
  String _currentCity;
  List _cities = ["45" ,"35", "25", "0"];

  List<TextEditingController> get_price = new List();
  List selected = new List();
  Set _special_lities = new Set();
  List select = new List();
  bool progress = false;
  String varience_option = "";
  List procedure_name = new List();
  List procedure_text_price = new List();
  List selected_pro_name = new List();
  List selected_varience = new List();
  List selected_procedure_text_price = new List();
  List selected_procedure_id = new List();
  List procedureIds = new List();
  List service_submit = new List();

  @override
  void initState() {
    getshareference();
    super.initState();
  }



  List name_ = new List();
  List price_ = new List();
  List varience_ = new List();

  List<DropdownMenuItem<String>> getDropDownMenuItems2() {
    List<DropdownMenuItem<String>> items = new List();

    for (String city in _cities) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(
        value: city,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: new Text(
            "±"+city + "%",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }
    return items;
  }



  // here we are creating the list needed for the DropDownButton
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();

    for (String speciality in _special_lities) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(value: speciality,
          child: new Text(speciality,
            style: TextStyle(fontSize: 12, color: Colors.black,),)
      ),
      );
    }
    return items;
  }



  getshareference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");

    for(int i =0; i< service.length; i++) {
      String speciality_id = service[i].specialityId;
      int pos = config.Config.specialist_id.indexOf(speciality_id);
      _special_lities.add(config.Config.specialist_lists[pos]);
    }

    _dropDownMenuItems2 = getDropDownMenuItems2();
    _currentCity = _dropDownMenuItems2[0].value;


    _dropDownMenuItems = getDropDownMenuItems();
    _speciality = _dropDownMenuItems[0].value;

    setState(() {
      user_token = token;
    });

    get_data();
  }

  void get_data() async{
    select.clear();
    procedure_name.clear();
    procedureIds.clear();
    procedure_text_price.clear();
    selected.clear();

    setState(() {
      call = false;
    });

      for(int j =0; j< config.Config.procedure_speciality.length; j++){
        if(config.Config.procedure_speciality[j].contains(_speciality)){
          print(config.Config.procedure_name[j]);
          procedure_name.add(config.Config.procedure_name[j]);
          select.add(false);
          selected.add("0");
          procedure_text_price.add("0");
        }
      }


    for(int i =0; i< config.Config.catalogueLists.length; i++){
      if(config.Config.catalogueLists[i].speciality == _speciality){
        for(int j =0; j< config.Config.catalogueLists[i].procedureData.length; j++){
          procedureIds.add(config.Config.catalogueLists[i].procedureData[j].id);
        }
      }
    }

    setState(() {
      call = true;
    });

  }



  void submit() async{
    price_.clear();
    varience_.clear();
    service_submit = [];
    setState(() {
      progress = true;
    });

    String specialisty_id ="";
    List<String>  procedurePrice = new List();
    List<String>  selectedVariance = new List();
    for(int i =0; i< config.Config.specialist_lists.length; i++){
      int pos = config.Config.specialist_lists.indexOf(_speciality);
       specialisty_id = config.Config.specialist_id[pos];
    }

    for(int i =0; i< procedure_text_price.length; i++){
      if(select[i]){
        procedurePrice.add(procedure_text_price[i]);
        selectedVariance.add(selected[i]);

      }
    }

    for(int i =0; i< selected_procedure_id.length; i++) {
      service_submit.add({
        "specialityId":specialisty_id,
        "serviceId":selected_procedure_id[i],
        "price":int.parse(procedurePrice[i]),
        "variance":int.parse(selectedVariance[i])
      });
    }
    var body = {
      "services": service_submit
    };

    print(body);

    EditCataloguePost editCatalogue = await edit_catalogue(body,user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");

      setState(() {
        progress = false;
      });
    });

    setState(() {
      print(editCatalogue.success);

      if(editCatalogue.success){
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (
              BuildContext context,
              ) =>
              _popup_saved(context),
        );
      }else{
        config.Config.showInSnackBar(_scaffoldKey, editCatalogue.message, Colors.red);
      }
      progress = false;

    });
  }

  void showInSnackBar(String value, MaterialColor color) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      backgroundColor: color,
    ));
  }


  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        "Add Catalogue",
        style: TextStyle(color: Colors.black),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: app_bar,

      body:Container(
        margin: EdgeInsets.all(20),

        child: Column(
          children: <Widget>[

            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 1, color: Color(0xff01d35a))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField(
                  hint: Text(
                    "Choose Speciality", style: TextStyle(color: Colors.white),),
                  value: _speciality,
                  decoration: InputDecoration.collapsed(hintText: "Choose Speciality",
                      hintStyle: TextStyle(color: Colors.black),
                      hasFloatingPlaceholder: true, fillColor: Colors.white),
                  items: _dropDownMenuItems,
                  onChanged: (val){

                    print(val);

                    setState(() {
                      _speciality = val;
                      get_data();
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Expanded(child: Text("Procedure", style: TextStyle(fontWeight:FontWeight.w600),), flex: 2,),

                Expanded(child: Text("Price", style: TextStyle(fontWeight:FontWeight.w600),), flex: 1,),

                Text("Varience", style: TextStyle(fontWeight:FontWeight.w600),),
                SizedBox(width: 20,),
              ],
            ),

             Expanded(
              child: call? procedure_name.length == 0? Center(
                child: Text("No result"),
              ): ListView.builder(itemBuilder: (context, index) {


                get_price.add(new TextEditingController());

                if(procedure_text_price[index].toString() == 'null'){
                  get_price[index].text = '';
                }else{
                  get_price[index].text = procedure_text_price[index].toString();

                }


                return Container(
                  child: InkWell(
                    onTap: () {
                      if (procedure_text_price[index] == '0' || procedure_text_price[index] == '')
                        showInSnackBar('Procedure price can not be 0 or empty. Please enter price!', Colors.red);
                      else {
                        setState(() {
                          select[index] = !select[index];
                        });


                        if(!selected_procedure_id.contains(procedureIds[index]))
                          selected_procedure_id.add(procedureIds[index]);
                        else
                          selected_procedure_id.remove(procedureIds[index]);
                      }

                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top:8.0, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[

                        Container(
                          child: Checkbox(
                          value: select[index], onChanged: (val) {
                            if (procedure_text_price[index] == '0' || procedure_text_price[index] == '')
                              showInSnackBar('Procedure price can not be 0 or empty. Please enter price!', Colors.red);
                            else {
                              setState(() {
                                select[index] = !select[index];
                              });
                              if(!selected_procedure_id.contains(procedureIds[index]))
                                selected_procedure_id.add(procedureIds[index]);
                              else
                                selected_procedure_id.remove(procedureIds[index]);
                            }


                          }),
                        ),


                        Expanded(
                            child: Text(procedure_name[index]),
                            ),

                          SizedBox(width: 10,),

                          Text("₹"),

                          Container(
                            width: 80,
                            child: TextField(
                              maxLength: 6,
                              controller: get_price[index],

                              onChanged:(text){
                                if(text != ''){
                                  procedure_text_price[index] = text;
                                }else{
                                  procedure_text_price[index] = '0';
                                }
                              },

                              decoration: InputDecoration(
                                counterText: '',
                                  hintText:  "price",
                                  hintStyle: TextStyle(color: Colors.grey)),
                              keyboardType: TextInputType.number,
                            ),
                          ),



                          Container(
                            width: 100,
                            child: DropdownButtonFormField(
                              value:selected[index],
                              items: _dropDownMenuItems2,
                              decoration:
                              InputDecoration.collapsed(
                                  hintText: "",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          10),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .grey)
                                  )),
                              onChanged: (newValue) {
                                setState(() {

                                  // int pos = _cities_name.indexOf(newValue);
                                  //  print(pos);


//                                  String varience = "0";
//                                  if(newValue == "Max (~ 45%)"){
//                                    varience = "45";
//                                  }else if(newValue == "Mid (~35%)"){
//                                    varience = "35";
//                                  }else if(newValue == "Mid (~35%)"){
//                                    varience = "25";
//                                  }else {
//                                    varience = "0";
//                                  }


                                  selected[index] = newValue;
                                });
                              },
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                );
              }, itemCount: procedure_name.length):SpinKitWanderingCubes(
                      color: Color(0xff01d35a),
                      size: 50.0,
                  // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                  ),
            ),


            progress? SpinKitThreeBounce(
              color: Color(0xff01d35a),
              size: 30.0,
              // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
            ): InkWell(
              onTap:submit,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                    color:Color(0xff01d35a)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Submit", style: TextStyle(color: Colors.white),),
                ),
              ),
            ),






          ],
        ),
      ),
    );
  }


  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Saved..'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(screen: "profile"),
                ));

          },
          child: new Text(
            'OK',
            style: TextStyle(color: Color(0xff01d35a)),
          ),
        ),
      ],
    );
  }

  Widget _popup(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Invalid'),
      content: new Text('Invalid Data'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text(
            'Try Again!',
            style: TextStyle(color: Color(0xff01d35a)),
          ),
        ),
      ],
    );
  }


}
