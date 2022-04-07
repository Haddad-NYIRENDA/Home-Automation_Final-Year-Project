import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shautom/views/components/graph.dart';
import 'package:shautom/views/components/readings.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:intl/intl.dart';

var formatter = NumberFormat.decimalPattern('en_us');
//var decimalFormatter = NumberFormat.0

/// Monitoring Dashboard Stateful Widget
class MonitorPage extends StatefulWidget {
  MonitorPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  /// State variables
  int temperature = 26;
  bool tempOkay = true;
  bool humidityOkay = false;
  int humidity = 30;

  double energy = 0;

  /// Firebase Realtime Database reference and event stream
  late DatabaseReference _dhtRef;
  late Stream<DatabaseEvent> _dhtStream;

  /// Initializes Firebase realtime database configuration & state
  Future<void> init() async {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    _dhtRef = FirebaseDatabase.instance
        .ref("Shautom/User/2vtcqvRNBVUPi0XtnxbUJRAy9GE2/sensor_readings/");

    _dhtStream = _dhtRef.onValue;
    _dhtStream.listen(
      (DatabaseEvent evt) {
        final data = evt.snapshot.value as Map;
        Map dhtData = data['DHT22'];
        Map power = data['Power'];
        print("DHT : $dhtData \n Power : $power");

        setState(() {
          temperature = dhtData['temperature'].truncate();
          tempOkay = temperature <= 28;
          humidity = dhtData['humidity'].truncate();
          humidityOkay = humidity >= 30 && humidity <= 50;
          energy = power['energy'].toDouble();
        });
      },
    );
  }

  /// Initializes widget state
  @override
  void initState() {
    init();
    super.initState();
  }

  /// Memory garbage collection method
  @override
  void dispose() {
    _dhtStream.drain();
    //_dhtRef.onDisconnect();
    super.dispose();
  }

  /// Renders a SingleChildScrollView of components
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Row(children: [
            Text(
              "Temperature & Humidity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ]),
          Divider(
            thickness: 2,
            color: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
              height: size.height * 0.25,
              child: GridView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 20),
                  physics: BouncingScrollPhysics(),
                  children: [
                    GridTile(
                      child: StreamBuilder(
                          stream: _dhtRef.onValue,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            } else if (snapshot.hasData) {
                              DatabaseEvent evt =
                                  snapshot.data as DatabaseEvent;
                              dynamic data = evt.snapshot.value as Map;
                              int val = (data['DHT22']['temperature']).toInt();
                              return TemperatureWidget(temperature: val);
                            } else if (snapshot.hasError) {
                              print("Error");
                            }
                            return Container();
                          }),
                      footer: Container(
                        padding: EdgeInsets.all(0),
                        child: GridTileBar(
                          title: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              "Temperature",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          leading: CircleAvatar(
                              backgroundColor:
                                  tempOkay ? Colors.green : Colors.red,
                              maxRadius: size.width * 0.02),
                          subtitle: Container(
                            margin: EdgeInsets.only(left: 10),
                            child: tempOkay
                                ? Text(
                                    "Okay",
                                    style: TextStyle(color: Colors.black),
                                  )
                                : Text("Critical",
                                    style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                    ),
                    GridTile(
                        child: StreamBuilder(
                            stream: _dhtRef.onValue,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasData) {
                                DatabaseEvent evt =
                                    snapshot.data as DatabaseEvent;
                                dynamic data = evt.snapshot.value as Map;
                                int val = (data['DHT22']['humidity']).toInt();
                                return HumidityWidget(humidity: val);
                              } else if (snapshot.hasError) {
                                print("Error");
                              }
                              return Container();
                            }),
                        footer: Container(
                          padding: EdgeInsets.all(0),
                          child: GridTileBar(
                            title: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                "Humidity",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ),
                            leading: CircleAvatar(
                                backgroundColor:
                                    !humidityOkay ? Colors.red : Colors.green,
                                maxRadius: size.width * 0.02),
                            subtitle: Container(
                              margin: EdgeInsets.only(left: 10),
                              child: humidityOkay
                                  ? Text(
                                      "Okay",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  : Text("Critical",
                                      style: TextStyle(color: Colors.black)),
                            ),
                          ),
                        )),
                  ])),
          Row(children: [
            Text(
              "Power Consumption",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ]),
          Divider(
            thickness: 2,
            color: Colors.black,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [Text("General")],
          ),
          Divider(color: Colors.black),
          SizedBox(
            height: size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  border:
                      Border.all(color: Colors.blue.withOpacity(0.6), width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              // child: Center(
              //     child: Text(
              //   "No Data",
              //   style: TextStyle(color: Colors.white.withOpacity(0.8)),
              // )),
              child: Row(
                children: [Flexible(child: LivePowerGraph())],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
