package com.kotelnikov.battery_indicator

import android.content.*
import android.os.BatteryManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** BatteryIndicatorPlugin */
class BatteryIndicatorPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var binding: ActivityPluginBinding

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "battery_indicator")
    channel.setMethodCallHandler(this)
  }

   override fun onAttachedToActivity(binding: ActivityPluginBinding) {
     this.binding = binding

     var onBatteryPowerChangedReceiver : BroadcastReceiver = object : BatteryPowerChangedReceiver(){
       override fun onReceive(context: Context?, intent: Intent?) {
         channel.invokeMethod("onBatteryPowerChanged", getBatteryPower())
       }
     }

     binding.activity.registerReceiver(onBatteryPowerChangedReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "onBatteryPowerChanged") {
      val batteryLevel = getBatteryPower()

      if (batteryLevel != -1) {
        result.success(batteryLevel)
      } else {
        result.error("ERROR", "Battery level not available.", null)
      }
    } else {
      result.notImplemented()
    }
  }

  private fun getBatteryPower(): Int{
    val batteryPower: Int

    val intent = ContextWrapper(binding.activity.application.applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))

    batteryPower = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)

    return batteryPower
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {}

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

  override fun onDetachedFromActivityForConfigChanges() {}
}
