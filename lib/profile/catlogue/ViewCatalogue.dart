import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:plunes/profile/catlogue/AddCatalogue.dart';
import 'package:plunes/config.dart' as config;


class ViewCatalogue extends StatefulWidget {
  static const tag = '/viewcatalogue';
  final List<ProcedureData> services;
  ViewCatalogue({Key key, this.services}) : super(key: key);


  @override
  _ViewCatalogueState createState() => _ViewCatalogueState(services);
}

class _ViewCatalogueState extends State<ViewCatalogue> {
  List<ProcedureData> services;
  _ViewCatalogueState( this.services);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List service_id = new List();

  List service_name = new List();
  List price = new List();
  List varience = new List();

  List selected = new List();
  List selected_procedure = new List();
  List selected_price = new List();
  List selected_varience = new List();

  bool delete = false;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < services.length; i++) {
      for (int j = 0; j < services[i].services.length; j++) {
        service_id.add(services[i].services[j].serviceId);
        price.add(services[i].services[j].price[0]);
        varience.add(services[i].services[j].variance);
        selected.add(false);
      }
    }

    for (int i = 0; i < service_id.length; i++) {
      int pos = config.Config.procedure_id.indexOf(service_id[i]);
      String name = config.Config.procedure_name[pos];
      service_name.add(name);
    }
    try{
      var listName = [];
      for (var j = 0; j < config.Config.catalogueLists.length; j++) {
        for (int k = 0; k < services[0].services.length; k++) {
          if (config.Config.catalogueLists[j].speciality_id == services[0].services[k].serviceId)
            listName.add(config.Config.catalogueLists[j].speciality);
        }
    }
      print('newList $listName');

    }catch(e){
      print('error $e');

    }


  }
  void update_catalogue(){


  }

  @override
  Widget build(BuildContext context) {

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        "Catalogue",
        style: TextStyle(color: Colors.black),
      ),

      actions: <Widget>[

        Visibility(
          visible: delete,
          child: Container(
            child: CupertinoButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red),),
              onPressed:(){


              }
            ),
          ),
        ),



      ],
    );


    final head_line = Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: <Widget>[

          Visibility(
            visible: delete,
            child: Expanded(
                flex: 1,
                child: Text(
                  "Choose",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          ),



          Expanded(
              flex: 3,
              child: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),


          Expanded(
              flex: 1,
              child:
              Container(child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold)),
                alignment: Alignment.center,)),


          Expanded(
              flex: 1,
              child: Container(
                child: Text(
                  "Variance",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                alignment: Alignment.center,
              )),


        ],
      ),
    );

    final catalogue_list = Expanded(
      child:service_name.length == 0? Center(
        child: Text("You haven't added any services in your catalogue yet.", style: TextStyle(fontSize: 14, color: Colors.grey),),
      ): ListView.builder(itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Visibility(
                visible: delete,
                child: Expanded(
                    flex: 1,
                    child: Checkbox(value: selected[index], onChanged: (val){
                      setState(() {
                        selected[index] = val;

                        if(selected[index]){

                          selected_varience.removeAt(index);
                          selected_procedure.removeAt(index);
                          selected_price.removeAt(index);

                          selected[index] = false;

                          if(selected_procedure.length ==0){
                            delete = false;
                          }
                        }else{

                          selected[index] = true;

                          selected_varience.add(varience[index]);
                          selected_procedure.add(service_name[index]);
                          selected_price.add(price[index]);

                        }


                      });
                    })),
              ),

              Expanded(child: Text(service_name[index]), flex: 3,),
              Expanded(child: Container(child: Text("₹ "+price[index].toString()), alignment: Alignment.center,), flex: 1,),
              Expanded(child: Container(child: Text(varience[index]+"%"), alignment: Alignment.center,), flex: 1,),
            ],
          ),
        );
      },itemCount: service_name.length,),
    );

    final form = Container(

      child: Column(
        children: <Widget>[
        service_name.length ==0? Container(): head_line,
        catalogue_list,

          SizedBox(height: 10,),

          service_name.length ==0? Container():  Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color(0xfff2f2f2),),
            margin: EdgeInsets.only(left:20, right: 60, bottom:10, top: 20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "To change price or variance in catalogue, please add again with new price and variance. ",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),

        ],
      ),
    );

    return Scaffold(
      appBar: app_bar,
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: form,
      floatingActionButton: FloatingActionButton(
        onPressed: (){


          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChooseSpeciality(
                service: services,
                ),
              ));


        },
        child: Icon(Icons.add, color: Colors.white,),
        shape: CircleBorder(side: BorderSide(color: Colors.transparent, width: 4.0)),
      ),
    );
  }
}
