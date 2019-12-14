package com.rithvij.launcher_utils_example

import android.os.Bundle
import com.rithvij.launcher_utils.LauncherUtilsPlugin
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        // doc: Call this method in the MainActivity to make the flutterView transparent
        // NOTE: Accessibility features might not work after making the flutterView transparent
        // Look at this issue for more details https://github.com/flutter/flutter/issues/37025
        LauncherUtilsPlugin.enableTransparency(flutterView)
    }

    // TODO: Important: The manifest should have android:theme="@style/Theme.Transparent" or some style which shows wallpaper
    // For the app to open transparently
}
