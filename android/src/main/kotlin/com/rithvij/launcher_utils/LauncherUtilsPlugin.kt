package com.rithvij.launcher_utils

import android.app.PendingIntent
import android.app.WallpaperManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.pm.ApplicationInfo
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import io.flutter.view.FlutterView
import java.io.ByteArrayOutputStream

class LauncherUtilsPlugin(private var registrar: PluginRegistry.Registrar) : MethodCallHandler {
    private val wallpaperManager: WallpaperManager = WallpaperManager.getInstance(this.registrar.context())
    private val applicationContext = registrar.context()
    private val packageManager = applicationContext.packageManager

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "launcher_utils")
            val plugin = LauncherUtilsPlugin(registrar)
            channel.setMethodCallHandler(plugin)
        }

        @JvmStatic
        fun disableTransparency(view: FlutterView) {
            view.setZOrderMediaOverlay(false)
            view.holder.setFormat(PixelFormat.OPAQUE)
        }

        @JvmStatic
        fun enableTransparency(view: FlutterView) {
            // Make flutter view transparent
            // https://github.com/flutter/flutter/issues/37025
            view.setZOrderMediaOverlay(true)
            view.holder.setFormat(PixelFormat.TRANSPARENT)
            // view.enableTransparentBackground()
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getWallpaper" -> {
                getWallpaper(result)
            }
            "getLockScreen" -> {
                getLockScreen(result)
            }
            "getPlatformVersion" -> {
                result.success(Build.DEVICE)
            }
            "enableTransparency" -> {
                enableTransparency()
                result.success(true)
            }
            "disableTransparency" -> {
                disableTransparency()
                result.success(true)
            }
            "isLiveWallpaper" -> {
                result.success(wallpaperManager.wallpaperInfo != null)
            }
            "isSetWallpaperAllowed" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    result.success(wallpaperManager.isSetWallpaperAllowed)
                } else {
                    result.error("requiresApi", "Requires Android N", null)
                }
            }
            "isWallpaperSupported" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    result.success(wallpaperManager.isWallpaperSupported)
                } else {
                    result.error("requiresApi", "Requires Android M", null)
                }
            }
            "setWallpaper" -> {
                if (call.hasArgument("image")) {
                    setWallpaper(call.argument<ByteArray>("image"))
                } else {
                    var useChooser = false
                    if (call.hasArgument("chooser")) {
                        useChooser = call.argument<Boolean>("chooser")!!
                    }
                    setWallpaper(useChooser)
                }
                result.success(true)
            }
            "openLiveWallpaperChooser" -> {
                openLiveWallpaperChooser(result)
            }
            "openLiveWallpaperSettings" -> {
                openLiveWallpaperSettings(result)
            }
            "launchApp" -> {
                launchApp(call.argument<String>("package"), result)
            }
            "getWallpaperProviders" -> {
                result.success(getWallpaperProviders())
            }
            "getDebugApps" -> {
                result.success(getDebugApps())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // https://stackoverflow.com/a/59242174/8608146
    private fun getDebugApps(): ArrayList<String> {
        val allIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val allApps = packageManager.queryIntentActivities(allIntent, 0)
        val debugApps = arrayListOf<ActivityInfo>()
        val ret = arrayListOf<String>()
        allApps.forEach {
            val appInfo = packageManager.getApplicationInfo(it.activityInfo.packageName, 0)
            if (0 != appInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) {
                debugApps.add(it.activityInfo)
                ret.add(it.activityInfo.packageName)
            }
        }
        return ret
    }

    // Returns the list of all apps that can set the wallpaper
    private fun getWallpaperProviders(): ArrayList<String> {
        val intent = Intent(Intent.ACTION_SET_WALLPAPER)

        // https://stackoverflow.com/a/18068122/8608146 this link is useful
        val providers = packageManager.queryIntentActivities(intent, 0)
        val ret = arrayListOf<String>()
        providers.forEach {
            Log.d("LauncherUtils", it.activityInfo.packageName)
            Log.d("LauncherUtils", it.activityInfo.targetActivity)
            ret.add(it.activityInfo.packageName)
        }
        return ret
    }

    // A function to make flutter view transparent
    private fun enableTransparency() {
        val view = registrar.view()
        // Make flutter view transparent
        // https://github.com/flutter/flutter/issues/37025
        view.setZOrderMediaOverlay(true)
        view.holder.setFormat(PixelFormat.TRANSPARENT)
        // view.enableTransparentBackground()
    }

    private fun disableTransparency() {
        val view = registrar.view()
        view.setZOrderMediaOverlay(false)
        view.holder.setFormat(PixelFormat.OPAQUE)
    }

    private fun launchApp(packageName: String?, result: MethodChannel.Result) {
        if (packageName != null) {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                startActivity(intent)
                result.success(true)
            } else {
                result.error("appNotFound", "The app $packageName doesn't exist", null)
            }
        } else {
            result.error("nullPackage", "The argument packageName provided should not be null", null)
        }
    }

    // https://stackoverflow.com/a/53967444/8608146
    private fun getLockScreen(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val drawable = wallpaperManager.getBuiltInDrawable(WallpaperManager.FLAG_LOCK)
            val bitmap = (drawable as BitmapDrawable).bitmap
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            result.success(stream.toByteArray())
        } else {
            result.error("requiresApi", "Requires android N", null)
        }
    }

    private fun getWallpaper(result: MethodChannel.Result) {
//        if (wallpaperManager.wallpaperInfo != null) {
//            result.success(wallpaperManager.wallpaperInfo.packageName)
//        } else {
        if (wallpaperManager.drawable is BitmapDrawable) {
            print("it is")
            print(wallpaperManager.drawable is BitmapDrawable)
        }
        val bitmap = (wallpaperManager.drawable as BitmapDrawable).bitmap
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        result.success(stream.toByteArray())
//        }
    }

    // This just opens the chooser based on the flag
    private fun setWallpaper(useChooser: Boolean) {
        val intent = Intent(Intent.ACTION_SET_WALLPAPER)

        if (useChooser) {
            // https://stackoverflow.com/a/19159291/8608146
            val receiver = Intent(applicationContext, EventsReceiver::class.java)
            val pendingIntent =
                    PendingIntent.getBroadcast(applicationContext, 0, receiver, PendingIntent.FLAG_UPDATE_CURRENT)
            // Create a chooser to prevent the user from checking don't ask again option
            val chooser = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                Intent.createChooser(intent, "Set Wallpaper", pendingIntent.intentSender)
            } else {
                Intent.createChooser(intent, "Set Wallpaper")
            }
            startActivity(chooser)
        } else {
            startActivity(intent)
        }
    }

    private fun setWallpaper(image: ByteArray?) {
        // TODO
    }


    private fun openLiveWallpaperChooser(result: MethodChannel.Result) {
        try {
            val intent = Intent(WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER)
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            // This would most likely never happen
            result.error("failed", "Opening Live Wallpaper chooser failed", e)
        }
    }

    private fun openLiveWallpaperSettings(result: MethodChannel.Result) {
        if (wallpaperManager.wallpaperInfo != null) {
            // If it is a live wallpaper
            var hasSettings = false
            // if it has a settings activity
            if (wallpaperManager.wallpaperInfo.settingsActivity != null) {
                Log.d("LauncherUtilsPlugin", wallpaperManager.wallpaperInfo.settingsActivity)
                hasSettings = true
            }

            if (hasSettings) {
                val intent = Intent()
                        .setClassName(
                                wallpaperManager.wallpaperInfo.packageName,
                                wallpaperManager.wallpaperInfo.settingsActivity
                        )
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                result.success(true)
            } else {
                result.error("noSettingsActivity", "The current live wallpaper does not have a settings screen", null)
            }
        } else {
            result.error("notALiveWallpaper", "The current wallpaper is not a live wallpaper", null)
        }
    }

    // Just a shortcut method instead of calling re.con().star.. every time
    private fun startActivity(intent: Intent) {
        registrar.context().startActivity(intent)
    }
}

// This needs to be in the app's android manifest file
// <receiver android:name="com.rithvij.launcher_utils.EventsReceiver" />
// A receiver to get which one was chosen from the wallpaper chooser
// Also the events from the wallpaper colors changed listener
// Also the events if the wallpaper has changed
class EventsReceiver : BroadcastReceiver() {
    override fun onReceive(p0: Context, p1: Intent) {
        // https://stackoverflow.com/questions/9583230/what-is-the-purpose-of-intentsender#comment72280489_34314156
        // EXTRA_CHOSEN_COMPONENT requires API 22
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            Log.d(
                    "MainActivity",
                    p1.extras?.getParcelable<ComponentName>(Intent.EXTRA_CHOSEN_COMPONENT)!!.toString()
            )
        }
    }
}
