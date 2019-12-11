package com.rithvij.home_launcher

import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class HomeLauncherPlugin : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "home_launcher")
            channel.setMethodCallHandler(HomeLauncherPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                result.success("Android ${Build.VERSION.BASE_OS}")
            } else {
                result.success("Android ${Build.VERSION.RELEASE}")
            }
        } else {
            result.notImplemented()
        }
    }
}
