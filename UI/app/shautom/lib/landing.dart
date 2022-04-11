import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:shautom/models/user.dart';
import 'package:shautom/views/components/graph.dart';
import 'package:shautom/views/components/readings.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

class LandingPage extends StatefulWidget {
  final UserModel? user;
  final bool loaded;
  final DatabaseReference dataRef;

  LandingPage({
    Key? key,
    required this.user,
    required this.loaded,
    required this.dataRef,
  }) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DatabaseReference sensorRef = widget.dataRef.child('sensor_readings');
    DatabaseReference applianceStateRef =
        widget.dataRef.child('appliance_status');
    return Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: GestureDetector(
                onTap: () => null,
                child: widget.loaded
                    ? RichText(
                        text: TextSpan(
                            style: TextStyle(
                              fontSize: 30,
                            ),
                            children: <InlineSpan>[
                            TextSpan(
                                text: "Welcome Home, \n",
                                style: TextStyle(color: Colors.black)),
                            TextSpan(
                                text: "${widget.user!.firstName}",
                                style: TextStyle(
                                  color: Colors.blueGrey.withOpacity(0.7),
                                  //fontStyle: FontStyle.italic
                                ))
                          ]))
                    : Text(''),
              )),
            ],
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          Container(
            margin: EdgeInsets.only(top: 0),
            height: size.height * 0.25,
            child: ListView(
              children: [
                Card(
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Colors.black.withOpacity(0.1), width: 2)),
                  child: Container(
                    padding: EdgeInsets.only(left: 6, top: 3),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.thermostat,
                              color: Colors.red.withOpacity(0.4),
                            ),
                            FittedBox(
                              child: Text(
                                "Temperature",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.height * 0.0015,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 5, top: 0),
                          height: size.height * 0.15,
                          child: Center(
                              child: StreamBuilder(
                            stream: sensorRef.onValue,
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snap.hasData) {
                                DatabaseEvent evt = snap.data as DatabaseEvent;
                                dynamic data = evt.snapshot.value as Map;
                                int val =
                                    (data['DHT22']['temperature']).toInt();
                                return Center(
                                    child: TemperatureGauge(value: val));
                              } else if (snap.hasError) {
                                print("Error");
                              }

                              return Container();
                            },
                          )),
                        )
                      ],
                    ),
                    width: size.width * 0.6,
                    height: size.height * 0.3,
                  ),
                ),
                Card(
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Colors.black.withOpacity(0.1), width: 2)),
                  child: Container(
                    padding: EdgeInsets.only(left: 6, top: 3),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(children: [
                          Icon(
                            MaterialCommunityIcons.water_percent,
                            color: Colors.blue.withOpacity(0.4),
                          ),
                          SizedBox(width: 5),
                          FittedBox(
                              child: Text(
                            "Humidity",
                            style: TextStyle(fontSize: 16),
                          ))
                        ]),
                        Container(
                            padding: EdgeInsets.only(bottom: 5, top: 0),
                            height: size.height * 0.15,
                            child: StreamBuilder(
                              stream: sensorRef.onValue,
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snap.hasData) {
                                  DatabaseEvent evt =
                                      snap.data as DatabaseEvent;
                                  dynamic data = evt.snapshot.value as Map;
                                  int val =
                                      data['DHT22']['humidity'].truncate();
                                  return Center(
                                      child: HumidityGauge(value: val));
                                } else if (snap.hasError) {
                                  print("Error");
                                }

                                return Container();
                              },
                            )),
                      ],
                    ),
                    width: size.width * 0.6,
                    height: size.height * 0.3,
                  ),
                ),
                Card(
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Colors.black.withOpacity(0.1), width: 2)),
                  child: Container(
                    padding: EdgeInsets.only(left: 6, top: 3),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisSize: MainAxisSize.max, children: [
                          Icon(
                            Icons.bolt,
                            color: Colors.red.withOpacity(0.4),
                          ),
                          FittedBox(
                            child: Text(
                              'Power',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ]),
                        SizedBox(
                          height: size.height * 0.015,
                        ),
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Kwh",
                                  style: TextStyle(
                                      color: Colors.red.withOpacity(0.6)),
                                ),
                                Odometer(),
                              ],
                            ),
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.withOpacity(0.7)),
                          ),
                        ),
                      ],
                    ),
                    width: size.width * 0.6,
                    height: size.height * 0.3,
                  ),
                ),
              ],
              scrollDirection: Axis.horizontal,
            ),
          ),
          SizedBox(height: 15),
          Text('Devices', style: TextStyle(fontSize: 25)),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(top: 0),
              height: size.height * 0.25,
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: Colors.black.withOpacity(0.1), width: 2)),
                    child: Container(
                      padding: EdgeInsets.only(left: 6, top: 3),
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(children: [
                            Icon(
                              MaterialCommunityIcons.weather_sunny,
                              color: Colors.blue.withOpacity(0.4),
                            ),
                            SizedBox(width: 5),
                            FittedBox(
                                child: Text(
                              "Indoor Lights",
                              style: TextStyle(fontSize: 14),
                            ))
                          ]),
                          Container(
                            padding: EdgeInsets.only(bottom: 5, top: 0),
                            height: size.height * 0.15,
                            child: Center(
                              child: StreamBuilder(
                                stream: applianceStateRef.onValue,
                                builder: (context, snap) {
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snap.hasData) {
                                    DatabaseEvent evt =
                                        snap.data as DatabaseEvent;
                                    dynamic data = evt.snapshot.value as Map;
                                    int lightState = data['roombulb']['state'];
                                    return CircleAvatar(
                                      maxRadius: 25,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black,
                                        maxRadius: 20,
                                        child: lightState == 1
                                            ? Text("ON")
                                            : Text(
                                                "OFF",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                      ),
                                    );
                                  } else if (snap.hasError) {
                                    print("Error");
                                  }

                                  return Container();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      width: size.width * 0.5,
                      height: size.height * 0.23,
                    ),
                  ),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: Colors.black.withOpacity(0.1), width: 2)),
                    child: Container(
                      padding: EdgeInsets.only(left: 6, top: 3),
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisSize: MainAxisSize.max, children: [
                            Icon(
                              MaterialCommunityIcons.air_conditioner,
                              color: Colors.red.withOpacity(0.4),
                            ),
                            SizedBox(width: 5),
                            FittedBox(
                              child: Text(
                                'Air Conditioning',
                                style: TextStyle(fontSize: 14),
                              ),
                            )
                          ]),
                          Container(
                            padding: EdgeInsets.only(bottom: 5, top: 0),
                            height: size.height * 0.15,
                            child: Center(
                              child: StreamBuilder(
                                stream: applianceStateRef.onValue,
                                builder: (context, snap) {
                                  if (snap.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snap.hasData) {
                                    DatabaseEvent evt =
                                        snap.data as DatabaseEvent;
                                    dynamic data = evt.snapshot.value as Map;
                                    int acState = data['fan']['state'];
                                    return CircleAvatar(
                                      maxRadius: 25,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black,
                                        maxRadius: 20,
                                        child: acState == 1
                                            ? Text("ON")
                                            : Text(
                                                "OFF",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                      ),
                                    );
                                  } else if (snap.hasError) {
                                    print("Error");
                                  }

                                  return Container();
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      width: size.width * 0.5,
                      height: size.height * 0.3,
                    ),
                  ),
                ],
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        ]);
  }
}


/*
CircleAvatar(
                    minRadius: size.width * 0.25,
                    backgroundColor: Colors.blue.withOpacity(0.8),
                    child: CircleAvatar(
                      minRadius: size.width * 0.18,
                      maxRadius: size.width * 0.2,
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: Text("${formatter.format(energy)} Wh"),
                    ),
                  ), */