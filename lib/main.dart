// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

// import 'snake.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0x9f4376f8),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double>? _magnetometerValues;
  double? magx;
  double? magy;
  double? magz;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  List<double> xValues = [];

  @override
  Widget build(BuildContext context) {
    final magnetometer =
        _magnetometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final magxs = magx?.toStringAsFixed(1);
    final magys = magy?.toStringAsFixed(1);
    final magzs = magz?.toStringAsFixed(1);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors Plus Example'),
        elevation: 4,
      ),
      body: ListView(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Magnetometer: $magnetometer'),
                Text('x: $magxs'),
                Text('y: $magys'),
                Text('z: $magzs'),
                Text('z: $xValues'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SfSparkLineChart(
              data: xValues,
            ),
          ),
          // Container(
          //     child: SfCartesianChart(
          //   primaryXAxis: NumericAxis(),
          //   primaryYAxis: NumericAxis(),
          //   series: <ColumnSeries<String, num>>[
          //     ColumnSeries<String, num>(
          //       dataSource: chartData,
          //       xValueMapper: (ChartSampleData data, _) => data.x,
          //       yValueMapper: (ChartSampleData data, _) => data.y,
          //       dataLabelSettings: DataLabelSettings(isVisible: true)
          //     ),
          //   ],
          // )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void addValue(double value) {
    if (xValues.length >= 10) {
      xValues.removeAt(0); // Remove the first (oldest) element
    }
    xValues.add(value);
  }

  @override
  void initState() {
    super.initState();

    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          setState(() {
            _magnetometerValues = <double>[event.x, event.y, event.z];
            magx = event.x;
            magy = event.y;
            magz = event.z;
            addValue(event.x);
            if (xValues.length >= 10) {
              xValues.removeAt(0); // Remove the first (oldest) element
            }
            xValues.add(event.x);
          });
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Magnetometer Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );
  }
}
