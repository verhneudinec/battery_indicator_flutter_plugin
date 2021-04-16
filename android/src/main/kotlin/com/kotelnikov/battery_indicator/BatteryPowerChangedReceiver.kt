package com.kotelnikov.battery_indicator

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel

private lateinit var channel : MethodChannel

abstract class BatteryPowerChangedReceiver : BroadcastReceiver() {
    /// OnReceive example:
    /// fun onReceive(context: Context, intent: Intent) {
    ///     channel.invokeMethod("onBatteryPowerChanged", getBatteryPower())
    /// }
}