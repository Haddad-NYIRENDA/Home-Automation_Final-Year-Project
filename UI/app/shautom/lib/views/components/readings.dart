import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TemperatureWidget extends StatelessWidget {
  final int temperature;

  TemperatureWidget({
    Key? key,
    required this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReadingWidget(reading: temperature, unit: "\u2103");
  }
}

class ReadingWidget extends StatelessWidget {
  final int? reading;
  final String? unit;

  ReadingWidget({this.reading, this.unit});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 45),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.blue,
            width: 4,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          )),
      child: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.8),
        minRadius: size.width * 0.14,
        maxRadius: size.width * 0.15,
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.6),
          minRadius: size.width * 0.12,
          maxRadius: size.width * 0.13,
          child: Center(
            child: Text(
              "$reading $unit",
              style: TextStyle(fontSize: size.height * 0.04),
            ),
          ),
        ),
      ),
    );
  }
}

class HumidityWidget extends StatelessWidget {
  final int humidity;

  HumidityWidget({
    Key? key,
    required this.humidity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ReadingWidget(
      reading: humidity,
      unit: "%",
    );
  }
}

class RadialGauge extends StatelessWidget {
  final String? unit;
  final int? reading;
  final int? maximum;

  RadialGauge({Key? key, this.reading, this.unit, this.maximum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
        showLabels: false,
        showTicks: false,
        startAngle: 180,
        endAngle: 90,
        minimum: 0,
        maximum: double.parse("$maximum"),
        radiusFactor: 0.9,
        axisLineStyle: AxisLineStyle(
          thicknessUnit: GaugeSizeUnit.factor,
          thickness: 0.2,
        ),
        annotations: <GaugeAnnotation>[
          GaugeAnnotation(
              angle: 0,
              widget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$reading"),
                  Text("$unit"),
                ],
              )),
        ],
        pointers: <GaugePointer>[
          RangePointer(
              value: double.parse("$reading"),
              cornerStyle: CornerStyle.bothCurve,
              enableAnimation: true,
              animationDuration: 1200,
              animationType: AnimationType.ease,
              sizeUnit: GaugeSizeUnit.factor,
              gradient: SweepGradient(
                  colors: <Color>[Color(0xFF6A6EF6), Color(0xFFDB82F5)],
                  stops: <double>[0.25, 0.75]),
              color: Color(0xFF00A8B5),
              width: 0.25),
        ],
      ),
    ]);
  }
}

class HumidityGauge extends StatelessWidget {
  final int? value;

  HumidityGauge({Key? key, this.value});

  @override
  Widget build(BuildContext context) {
    return RadialGauge(unit: "%", reading: value, maximum: 100);
  }
}

class TemperatureGauge extends StatelessWidget {
  final int? value;

  TemperatureGauge({Key? key, this.value});

  @override
  Widget build(BuildContext context) {
    return RadialGauge(unit: "\u2103", reading: value, maximum: 70);
  }
}
