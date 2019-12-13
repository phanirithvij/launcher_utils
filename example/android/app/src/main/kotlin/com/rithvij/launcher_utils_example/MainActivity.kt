package com.rithvij.launcher_utils_example

import android.os.Bundle
import com.rithvij.launcher_utils.LauncherUtilsPlugin

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        // doc: Call this method in the MainActivity to the flutterView transparent
        // Accessibility features might not work
        // https://github.com/flutter/flutter/issues/37025
        LauncherUtilsPlugin.enableTransparency(flutterView)

        // This can be used to disable transparency
        // Not very useful unless it is for debugging purposes
//        LauncherUtilsPlugin.disableTransparency(flutterView)

        // Set the transparent theme here instead of setting it in the manifest file
        // This is available in th launcher_utils/android/src/res/values/styles.xml
        setTheme(R.style.Theme_Transparent)
    }
}
