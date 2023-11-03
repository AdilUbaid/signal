import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';


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
  List<double> yValues = [];
  List<double> zValues = [];

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
        body: Builder(builder: (context) {
          return ListView(
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
                    // Text('z: $yValues'),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   // child: SingleChildScrollView(
              //   // scrollDirection: Axis.horizontal,
              //   child: Container(
              //     width: double.infinity,
              //     child: SfSparkLineChart(
              //       // color: Colors.red,
              //       // trackball: SparkChartTrackball(
              //       // activationMode: SparkChartActivationMode.tap),
              //       labelDisplayMode: SparkChartLabelDisplayMode.all,
              //       // marker: SparkChartMarker(
              //       // displayMode: SparkChartMarkerDisplayMode.high),

              //       data: xValues,
              //     ),
              //   ),
              // ),
              // Center(child: Text("X axis")),
              LiveChart(xValues, yValues),
              Center(child: Text("X axis")),
              LiveChart(yValues, yValues),
              Center(child: Text("Y axis")),
              LiveChart(zValues, yValues),
              Center(child: Text("Z axis")),
              // SfCartesianChart(
              //   primaryXAxis: NumericAxis(),
              //   title: ChartTitle(text: "x axis"),
              //   series: xValues,
              // )
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Container(
              //     width: double.infinity,
              //     child: SfSparkLineChart(
              //       labelDisplayMode: SparkChartLabelDisplayMode.all,
              //       // trackball: SparkChartTrackball(),
              //       data: yValues,
              //     ),
              //   ),
              // ),
              // Center(child: Text("Y axis")),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Container(
              //     width: double.infinity,
              //     child: SingleChildScrollView(
              //       scrollDirection: Axis.horizontal,
              //       child: SfSparkLineChart(
              //         // highPointColor: Colors.red,
              //         labelDisplayMode: SparkChartLabelDisplayMode.all,
              //         // marker: SparkChartMarker(),
              //         data: zValues,
              //       ),
              //     ),
              //   ),
              // ),
              // Center(child: Text("Z axis")),
            ],
          );
        }));
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void addValue(double value, List<double> array) {
    if (array.length >= 10) {
      array.removeAt(0); // Remove the first (oldest) element
    }
    array.add(value);
    setState(() {});
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
            addValue(event.x, xValues);
            addValue(event.y, yValues);
            addValue(event.z, zValues);
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

class LiveChart extends StatefulWidget {
  final List<double> xValues;
  final List<double> yValues;

  LiveChart(this.xValues, this.yValues);

  @override
  _LiveChartState createState() => _LiveChartState();
}

class _LiveChartState extends State<LiveChart> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      // Define your chart configuration here
      primaryXAxis: NumericAxis(),
      primaryYAxis: NumericAxis(),
      series: <LineSeries<ChartData, double>>[
        LineSeries<ChartData, double>(
          dataSource: widget.xValues
              .asMap()
              .entries
              .map((entry) => ChartData(entry.key.toDouble(), entry.value))
              .toList(),
          xValueMapper: (ChartData chartData, _) => chartData.x,
          yValueMapper: (ChartData chartData, _) => chartData.y,
        ),
      ],
    );
  }
}

class ChartData {
  final double x;
  final double y;

  ChartData(this.x, this.y);
}
