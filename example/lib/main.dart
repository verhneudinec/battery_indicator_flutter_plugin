import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const MethodChannel channel = const MethodChannel('battery_indicator');
const String getBatteryPowerChannelMethod = "onBatteryPowerChanged";

class _MyAppState extends State<MyApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  BatteryIndicator _batteryIndicatorManager;

  int _batteryPower = 100;
  bool _isSnackBarNotShown = true;
  double _batteryIconOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final int currentBatteryPower =
        await channel.invokeMethod(getBatteryPowerChannelMethod);

    setState(() {
      /// Initialize the plugin and pass the callback
      _batteryIndicatorManager = BatteryIndicator(_setBatteryPowerIndicator);

      /// Initialize the current battery value
      _batteryPower = currentBatteryPower;
    });

    if (!mounted) return;
  }

  /// Callback function to set battery value
  void _setBatteryPowerIndicator(int value) {
    if (value < 20 && _isSnackBarNotShown) {
      _messengerKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[400],
          content: Text('Connect your phone to charging'),
        ),
      );

      /// No more showing the SnackBar
      _isSnackBarNotShown = false;
    } else if (value > 30) {
      _batteryIconOpacity = _batteryPower / 100 ?? 1;
    }

    setState(() {
      _batteryPower = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[300],
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Battery indicator plugin'),
        ),
        body: Center(
          child: LimitedBox(
            maxWidth: 300,
            maxHeight: 300,
            child: Stack(
              children: [
                Align(
                  child: Opacity(
                    opacity: _batteryIconOpacity,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        Icons.battery_full,
                        size: 150,
                        color:
                            _batteryPower > 30 ? Colors.green[300] : Colors.red,
                      ),
                    ),
                  ),
                ),
                Align(
                  child: Text(
                    "$_batteryPower%",
                    style: TextStyle(
                      fontSize: 30,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
