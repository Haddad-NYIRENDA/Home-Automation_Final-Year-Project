import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'package:odometer/odometer.dart';

/// Power odometer widget
///
/// Shows the current power consumption reading
/// The readings are curretntly synthetic
class Odometer extends StatefulWidget {
  _OdometerState createState() => _OdometerState();
}

class _OdometerState extends State<Odometer> {
  /// The initial energy reading
  int _energy = 1972;

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 5), updateEnergy);
    super.initState();
  }

  updateEnergy(Timer timer) {
    if (mounted) {
      setState(() {
        _energy += 1;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlideOdometerNumber(
      odometerNumber: OdometerNumber(_energy),
      duration: Duration(milliseconds: 500),
      letterWidth: 35,
      numberTextStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w300,
          //backgroundColor: Colors.black.withOpacity(0.5),
          color: Colors.white),
    );
  }
}

/// A static energy graph
///
/// Synthetic as well
class PowerGraph extends StatefulWidget {
  @override
  _PowerGraphState createState() {
    return _PowerGraphState();
  }
}

class _PowerGraphState extends State<PowerGraph> {
  late List<EnergyData> _chartData;
  late TooltipBehavior _tooltipBehaviour;

  @override
  void initState() {
    _chartData = getEnergyData();
    _tooltipBehaviour = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: "Energy Consumption Analysis"),
      legend: Legend(isVisible: false, position: LegendPosition.top),
      tooltipBehavior: _tooltipBehaviour,
      series: <SplineAreaSeries>[
        SplineAreaSeries<EnergyData, double>(
            name: 'Energy Consumption',
            dataSource: _chartData,
            xValueMapper: (EnergyData energy, _) => energy.timestamp,
            yValueMapper: (EnergyData energy, _) => energy.value,
            dataLabelSettings: DataLabelSettings(isVisible: true),
            enableTooltip: true,
            color: Colors.blue,
            opacity: 0.6,
            splineType: SplineType.cardinal,
            cardinalSplineTension: 0.7,
            xAxisName: "Time",
            yAxisName: "Energy Value")
      ],
      primaryXAxis: NumericAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorGridLines: MajorGridLines(width: 0),
          title:
              AxisTitle(text: "Timestamp", alignment: ChartAlignment.center)),
      primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(width: 0),
          labelFormat: '{value}',
          title: AxisTitle(text: "Energy"),
          numberFormat: NumberFormat.decimalPattern("en-us")),
    );
  }

  List<EnergyData> getEnergyData() {
    final List<EnergyData> data = [
      EnergyData(timestamp: 0, value: 23),
      EnergyData(timestamp: 60, value: 78),
      EnergyData(timestamp: 123, value: 23),
      EnergyData(timestamp: 180, value: 89),
      EnergyData(timestamp: 240, value: 320)
    ];
    return data;
  }
}

/// Energy datapoint model class
class EnergyData {
  EnergyData({
    required this.timestamp,
    required this.value,
  });

  final double timestamp;
  final double value;
}

/// A dynamic live chart for energy data
///
/// Currently shows synthetic autogenerated random data
class LivePowerGraph extends StatefulWidget {
  @override
  State<LivePowerGraph> createState() => _LivePowerGraphState();
}

class _LivePowerGraphState extends State<LivePowerGraph> {
  late List<LiveEnergyData> _chartData;

  late TooltipBehavior _tooltipBehaviour;

  ChartSeriesController? _chartSeriesController;

  @override
  void initState() {
    _chartData = [
      LiveEnergyData(timestamp: 0, value: 23),
      LiveEnergyData(timestamp: 1, value: 78),
      LiveEnergyData(timestamp: 2, value: 23),
      LiveEnergyData(timestamp: 3, value: 89),
      LiveEnergyData(timestamp: 4, value: 320)
    ];

    _tooltipBehaviour = TooltipBehavior(enable: true);
    Timer.periodic(const Duration(seconds: 2), updateDataSource);
    super.initState();
  }

  @override
  void dispose() {
    _chartData.clear();
    _chartSeriesController = null;
    super.dispose();
  }

  double time = 5;

  /// Dynamicallys updates power chart data
  ///
  /// Periodically updates using [timer] as input
  void updateDataSource(Timer timer) {
    _chartData.add(LiveEnergyData(
        timestamp: time++, value: ((math.Random().nextDouble()) * 400)));
    _chartData.removeAt(0);
    _chartSeriesController?.updateDataSource(
      addedDataIndex: _chartData.length - 1,
      removedDataIndex: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      //title: ChartTitle(text: "Energy Consumption Anlaysis"),
      legend: Legend(isVisible: false),
      tooltipBehavior: _tooltipBehaviour,
      series: <SplineAreaSeries>[
        SplineAreaSeries<LiveEnergyData, double>(
            animationDuration: 2000,
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            name: 'Energy Consumption',
            dataSource: _chartData,
            xValueMapper: (LiveEnergyData energy, _) => energy.timestamp,
            yValueMapper: (LiveEnergyData energy, _) => energy.value,
            dataLabelSettings: DataLabelSettings(isVisible: false),
            enableTooltip: true,
            color: Colors.blue,
            opacity: 0.6,
            splineType: SplineType.cardinal,
            cardinalSplineTension: 0.7,
            xAxisName: "Time",
            yAxisName: "Energy Value")
      ],
      primaryXAxis: NumericAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          title:
              AxisTitle(text: "Timestamp", alignment: ChartAlignment.center)),
      primaryYAxis: NumericAxis(
          labelFormat: '{value}',
          title: AxisTitle(text: "Energy"),
          numberFormat: NumberFormat.decimalPattern("en-us")),
    );
  }
}

/// Dynamic energy data point model
class LiveEnergyData {
  LiveEnergyData({
    required this.timestamp,
    required this.value,
  });

  final double timestamp;
  final double value;
}
