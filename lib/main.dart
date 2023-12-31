import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  List<double> fieldValues = [];

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
                    Text("$fieldValues")
                  ],
                ),
              ),
              xValues.isEmpty
                  ? const CircularProgressIndicator()
                  : LiveChart(xValues, const []),
              const Center(child: Text("X axis")),
              xValues.isEmpty
                  ? const CircularProgressIndicator()
                  : LiveChart(yValues, const []),
              const Center(child: Text("Y axis")),
              xValues.isEmpty
                  ? const CircularProgressIndicator()
                  : LiveChart(zValues, const []),
              const Center(child: Text("Z axis")),
              fieldValues.isEmpty
                  ? const CircularProgressIndicator()
                  : LiveChart(fieldValues, const []),
              const Center(child: Text("magnetic field")),
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
      array.removeAt(0);
    }
    array.add(value);
    setState(() {});
  }

  calculateMagneticField(double x, double y, double z) {
    // Calculate the magnitude using the Pythagorean theorem
    double field = sqrt((x * x) + (y * y) + (z * z));
    // print("HElLLO");
    print(field.toString());
    addValue(field, fieldValues);
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
            // print("BEFORE CALL");
            addValue(event.x, xValues);
            addValue(event.y, yValues);
            addValue(event.z, zValues);
            
            calculateMagneticField(magx!, magy!, magz!);
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
