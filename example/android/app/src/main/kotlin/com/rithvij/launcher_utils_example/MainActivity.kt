package com.rithvij.launcher_utils_example

import android.content.res.Resources
import android.os.Bundle
import com.rithvij.launcher_utils.LauncherUtilsPlugin
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        // doc: Call this method in the MainActivity to make the flutterView transparent
        // Accessibility features might not work
        // https://github.com/flutter/flutter/issues/37025
        LauncherUtilsPlugin.enableTransparency(flutterView)
    }

    // Either override this function or use setTheme(resourceId) before super.onCreate
    // https://stackoverflow.com/q/11562051/8608146
    override fun getTheme(): Resources.Theme {
        val theme = super.getTheme()
        // Set the transparent theme here instead of setting it in the manifest file
        // This is available in the launcher_utils/android/src/res/values/styles.xml
        theme.applyStyle(R.style.Theme_Transparent, true)
        return theme
    }
}
