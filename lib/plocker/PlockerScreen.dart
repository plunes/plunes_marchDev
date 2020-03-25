import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plunes/plocker/LabReports.dart';
import 'package:plunes/plocker/Prescriptions.dart';
import 'package:plunes/profile/ProfileImage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlockerScreen extends StatefulWidget {
  static const tag = '/plocker';
  @override
  _PlockerScreenState createState() => _PlockerScreenState();
}

class _PlockerScreenState extends State<PlockerScreen> {

  var image;
  List lab_reports_list = new List();
  List prescriptions_list = new List();
  String user_token = "";
  String user_id = "";
  String user_type = "";
  String specialist = "";

  Future getImage(BuildContext context) async {
    image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    setState(() {
    });
  }


  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    String type = prefs.getString("user_type");
    String _specialist = prefs.getString("specialist");
    setState(() {
      user_token = token;
      user_id = uid;
      user_type = type;
      specialist = _specialist;

    });

  }

  void get_camera(BuildContext context) async {
    image = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    lab_reports_list.add('https://static.docsity.com/documents_pages/2013/01/17/183bfc76242bf495cd72008fb5035467.png');
    lab_reports_list.add('https://workbench-media-workbench-prod.s3.amazonaws.com/cwist/cwists/4e/6a/d6f2b906-4e6a-4660-8e08-0a62587d1eef_500_500.png');

    prescriptions_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    prescriptions_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');

    lab_reports_list.add('https://static.docsity.com/documents_pages/2013/01/17/183bfc76242bf495cd72008fb5035467.png');
    lab_reports_list.add('https://workbench-media-workbench-prod.s3.amazonaws.com/cwist/cwists/4e/6a/d6f2b906-4e6a-4660-8e08-0a62587d1eef_500_500.png');

    prescriptions_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    prescriptions_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');

    getSharedPreferences();


  }






  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[

                new ListTile(
                    leading: new Icon(Icons.camera),
                    title: new Text('Camera'),
                    onTap: () {
                      get_camera(context);
                      Navigator.pop(context);
                    }
                ),
                new ListTile(
                  leading: new Icon(Icons.image),
                  title: new Text('Gallery'),
                  onTap: () {
                    getImage(context);
                    Navigator.pop(context);
                  },
                ),

              ],
            ),
          );
        });
  }


  @override
  Widget build(BuildContext context) {

    final options_tabs = Container(
        padding: EdgeInsets.only(left:20, right: 20),
        child: DefaultTabController(
          length: 2,
         // initialIndex: screen,
          child: Column(
            children: <Widget>[

              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                constraints: BoxConstraints.expand(height: 30),
                //  foregroundDecoration: BoxDecoration(color:Colors.red),
                child: TabBar(
                  tabs: [

                    Tab(
                        text: "Personal"
                    ),
                    Tab(
                      text: "Business",
                    ),

                  ],
                  labelStyle:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff262626)),
                  indicatorColor: Color(0xff01d35a),
                  unselectedLabelColor: Color(0xff808080),
                  labelColor: Colors.black,
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 14, ),
                ),
              ),
              Expanded(
                child: Container(
                  child: TabBarView(
                    children: [
                      personnel(context),
                      business(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: user_type == 'User'? Container(
        child: personnel(context),
        margin: EdgeInsets.only(left:20, right: 20),
      ): options_tabs,
    );
  }


  Widget business(BuildContext context){

    return Container(

    );


  }



  Widget personnel(BuildContext context){
    return Container(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              radius: 10,
              onTap: (){
                _settingModalBottomSheet(context);
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Text("Upload Reports", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),),
                        Expanded(child: Container()),
                        Icon(Icons.cloud_upload)
                      ],
                    ),
                  ),
                ),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Color(0xffB8C5D0)),
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top:20),
            child: Row(
              children: <Widget>[
                Text("Prescription"),
                Expanded(child: Container()),
                InkWell(child: Text("View All"), onTap: (){
                  Navigator.pushNamed(context, Prescriptions.tag);
                },)
              ],
            ),
          ),

          Container(height: 200,
            child:prescriptions_list.length >0 ?ListView.builder(itemBuilder: (context, index){
             return Container(
              width: 130,
              height: double.infinity,
               decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                   border: Border.all(width: 0.5, color: Colors.grey)),
              child:InkWell(
                onTap: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context,) =>
                        ProfileImage(
                          image_url: prescriptions_list[index],
                          text: " ",
                        ),
                  );
                },
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(8.0),
                  child: Image.network(prescriptions_list[index],
                    fit: BoxFit.cover, height: double.infinity, width: double.infinity,),
                ),
              ),
              margin: EdgeInsets.all(10),
            );
          }, scrollDirection: Axis.horizontal, itemCount: prescriptions_list.length,): Center(
              child: Text("No Prescriptions Yet"),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top:20),
            child: Row(
              children: <Widget>[
                Text("Lab Reports"),
                Expanded(child: Container()),
                InkWell(child: Text("View All"), onTap: (){

                  Navigator.pushNamed(context, LabReports.tag);

                },)
              ],
            ),
          ),

          Container(height: 200,
            child:lab_reports_list.length > 0? ListView.builder(itemBuilder: (context, index){
              return Container(
                width: 130,
                height: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(width: 0.5, color: Colors.grey)),
                child: InkWell(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context,) =>
                          ProfileImage(
                            image_url: lab_reports_list[index],
                            text: " ",
                          ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(8.0),
                    child: Image.network(lab_reports_list[index],
                      fit: BoxFit.cover, height: double.infinity, width: double.infinity,),
                  ),
                ),
                margin: EdgeInsets.all(10),
              );
            }, scrollDirection: Axis.horizontal, itemCount: lab_reports_list.length,): Center(
              child: Text("No Reports Yet"),
            ),
          ),
        ],
      ),
    );



  }

}
