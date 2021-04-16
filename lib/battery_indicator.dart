import 'package:flutter/services.dart';

const onBatteryPowerChanged = "onBatteryPowerChanged";

/// Plugin to get battery changes
class BatteryIndicator {
  static const MethodChannel channel = const MethodChannel('battery_indicator');

  BatteryIndicator(this.batteryPowerListener) {
    _initBatteryIndicatorManager();
  }

  /// The function is called when the battery value changes.
  /// Accepts new battery power value.
  final Function(int) batteryPowerListener;

  void _initBatteryIndicatorManager() async {
    channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case (onBatteryPowerChanged):
            batteryPowerListener(call.arguments);
            break;
          default:
            print("An error occurred when calling the method ${call.method}");
        }
      },
    );
  }
}
