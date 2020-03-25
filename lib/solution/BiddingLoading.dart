import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plunes/solution/BiddingActivity.dart';
import 'package:plunes/solution/SolutionResults.dart';
import 'package:plunes/model/solution/find_solution.dart';
import '../config.dart';

class BiddingLoading extends StatefulWidget {
  static const tag = '/bidding_loading';

  final List<ServicesData> service_data;
  final int createdTime;
  final String serviceId;
  final String id_;
  final String screen, solutionType;

  BiddingLoading({Key key, this.service_data, this.createdTime, this.serviceId, this.id_, this.screen, this.solutionType}) : super(key: key);

  @override
  _BiddingLoadingState createState() => _BiddingLoadingState(service_data,
      createdTime, serviceId, id_,screen);
}

class _BiddingLoadingState extends State<BiddingLoading> {

 double  progress_bid = 0.0;
 Timer _timer;

 final List<ServicesData> service_data;
 final int createdTime;
 final String serviceId;
 final String id_;
 final String screen;
 int _start = 0;
 double moving = 110;

 _BiddingLoadingState(this.service_data, this.createdTime, this.serviceId, this.id_, this.screen);

 @override
 void initState() {
   // TODO: implement initState
   super.initState();
   start();

 }




   start() {
     _timer = new Timer(Duration(seconds: 1), () {
       setState(() {


         _start = _start + 1;
         if(_start > 9){

           if(screen == "single"){

             Navigator.pop(context);
             Navigator.push(
                 context,
                 MaterialPageRoute(
                     builder: (context) => SolutionResults(
                       service_data: service_data,
                       createdTime: createdTime,
                       serviceId: serviceId,
                       id_: id_,
                       position: 0,
                       solutionType: widget.solutionType,
                     )));

           }else{
             Navigator.pop(context);
             Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => BiddingActivity(screen:1, solutionType: widget.solutionType),
                 ));
           }
         } else{

           progress_bid  = progress_bid + 0.1;
           if(moving == 110){
             moving = 10;
           }else{
             moving = 110;
           }
           start();
         }



       });
     });
   }

 @override
 void dispose() {
   super.dispose();
   _timer.cancel();
 }


  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: ListView(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 100,),
              Stack(
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 150,
                    margin: EdgeInsets.only(top: 20, bottom: 10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                              gradient: new LinearGradient(
                                  colors: [Colors.white, Color(0xfffafafa)],
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  stops: [0.0, 1.0],
                                  tileMode: TileMode.clamp
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(75),),
                              border: Border.all(
                                  color: Color(0xfffafafa), width: 2)),
                        ),
                        Align(
                          child: AnimatedContainer(
                            duration: Duration(seconds: 1),
                            height: 70,
                            width: 70,
                            margin: EdgeInsets.only(top: moving),
                            child: Center(
                              child: Image.asset('assets/images/bid/bid_active.png', height: 70, width: 70,),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],

              ),
              SizedBox(
                height: 50,
              ),

              Center(
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 50),
                  child: Text("WE ARE GETTING THE BEST SOLUTIONS FOR YOU",
                    textAlign: TextAlign.center,
                    style: TextStyle(

                        fontSize: 16,
                        fontWeight: FontWeight.w500),),
                ),
              ),
              SizedBox(
                height: 170,
              ),
              Center(
                child: Text("Receiving...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
              ),
              Container(
                height: 3,
                margin: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                child: LinearProgressIndicator(
                  value:progress_bid,
                  backgroundColor: Color(0xffDCDCDC),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff01d35a),),
                ),
              ),
            ],
          )
        ],),
      ),


    );
  }
}
