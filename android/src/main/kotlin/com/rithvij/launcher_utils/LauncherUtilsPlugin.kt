package com.rithvij.launcher_utils

import android.app.PendingIntent
import android.app.WallpaperManager
import android.content.*
import android.content.pm.ActivityInfo
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.PixelFormat
import android.graphics.Rect
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import io.flutter.view.FlutterView
import java.io.ByteArrayOutputStream

const val tag = "LauncherUtils"
// This must be global so that all the receivers can access the event channel
lateinit var globalPlugin: LauncherUtilsPlugin

class LauncherUtilsPlugin(private var registrar: PluginRegistry.Registrar) : MethodCallHandler {
    private val wallpaperManager: WallpaperManager = WallpaperManager.getInstance(this.registrar.context())
    val applicationContext: Context = registrar.context()
    private val packageManager: PackageManager = applicationContext.packageManager
    val wallpaperListener = WallpaperListener()

    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), "launcher_utils/api")
            val pluginInstance = LauncherUtilsPlugin(registrar)
            channel.setMethodCallHandler(pluginInstance)

            globalPlugin = pluginInstance

            // To send events to the flutter side if the wallpaper changes
            val eventChannelName = "launcher_utils/events"
            EventChannel(registrar.view(), eventChannelName).setStreamHandler(pluginInstance.wallpaperListener)
        }

//        @JvmStatic
//        fun disableTransparency(view: FlutterView) {
//            view.setZOrderMediaOverlay(false)
//            view.holder.setFormat(PixelFormat.OPAQUE)
//        }

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
            "getWallpaperInfo" -> {
                // TODO: Create a method and a format to send info on the currently set wallpaper something like `getWallpaperInfo`
                // i.e. if it is a wallpaper send a thumbnail
                // if it is a live wallpaper send the live wallpaper's icon, etc..
                // So that the launcher can show this to the user as the currently set wallpaper
                result.notImplemented()
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
                    setWallpaper(call.argument<ByteArray>("image")!!, result)
                } else {
                    var useChooser = false
                    if (call.hasArgument("chooser")) {
                        useChooser = call.argument<Boolean>("chooser")!!
                    }
                    setWallpaper(useChooser)
                    result.success(true)
                }
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
            "wallpaperCommand" -> {
                // TODO : decide a name for this method
                // Forward gestures to the live wallpaper
                val args = call.arguments<ArrayList<Float>>()
                sendWallpaperEvents(args)
                result.success(true)
            }
            "getColors" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                    val ret = getColors()
                    result.success(ret)
                } else {
                    // TODO : Try an experimental extracting of colors if an argument is passed
                    // TODO : Useful for API < 27
                    result.error("requiresApi", "requires Oreo 8.1", null)
                }
            }
            "setWallpaperOffsets" -> {
                val args = call.arguments<ArrayList<Float>>()
                setWallpaperOffsets(args)
                result.success(true)
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
            Log.d(tag, it.activityInfo.packageName)
            Log.d(tag, it.activityInfo.targetActivity)
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

    // A function to undo enableTransparency
    private fun disableTransparency() {
        val view = registrar.view()
        view.setZOrderMediaOverlay(false)
        view.holder.setFormat(PixelFormat.OPAQUE)
    }

    // Launch an app based on it's package name
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

    // Get the lock screen image
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

    // Get the current wallpaper
    // Always returns a byte array
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

//    startActivity(new Intent(WallpaperManager.WALLPAPER_PREVIEW_META_DATA));


    // This just opens the chooser based on the flag
    private fun setWallpaper(useChooser: Boolean) {
        val intent = Intent(Intent.ACTION_SET_WALLPAPER)

        if (useChooser) {
            // https://stackoverflow.com/a/19159291/8608146
            val receiver = Intent(applicationContext, LauncherEventsReceiver::class.java)
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

    private fun setWallpaper(image: ByteArray, result: MethodChannel.Result) {
        var bitmap = BitmapFactory.decodeByteArray(image, 0, image.size)
        if (bitmap == null) {
            result.error("failed", "Decoding the image failed", null)
            return
        }
        Log.d(tag, "height: ${bitmap.height}, width: ${bitmap.width}")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (wallpaperManager.isSetWallpaperAllowed) {
                try {
//                    wallpaperManager.getCropAndSetWallpaperIntent(Uri.)
                    setWallpaperFromBitmap(bitmap)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("failed", "Setting the image as the wallpaper failed", e)
                }
            } else {
                result.error("failed", "Setting the image as the wallpaper failed", null)
            }
        } else {
            try {
                setWallpaperFromBitmap(bitmap)
                result.success(true)
            } catch (e: Exception) {
                result.error("failed", "Setting the image as the wallpaper failed", null)
            }
        }

        // clean up
        bitmap.recycle()
        bitmap = null
    }

    private fun setWallpaperFromBitmap(bitmap: Bitmap) {
        val metrics = DisplayMetrics()
        registrar.activity().windowManager.defaultDisplay.getMetrics(metrics)
        Log.d(tag, "screen height: ${metrics.heightPixels}, width: ${metrics.widthPixels}")
        wallpaperManager.run {
            val totWidth = bitmap.width * (metrics.heightPixels / metrics.widthPixels.toFloat())
            val onePageWidth = ((metrics.widthPixels / metrics.heightPixels.toFloat()) * bitmap.height).toInt()
            val numPages = (totWidth / onePageWidth).toInt()
            Log.d(tag, "Num pages is $numPages")
            Log.d(tag, "One page width is $onePageWidth")
            Log.d(tag, "Total width is $totWidth")
            val x = onePageWidth * 3
            val y = 0
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                setBitmap(
                        bitmap,
                        Rect(
                                x,
                                y,
                                onePageWidth + x,
                                bitmap.height + y
                        ),
                        false,
                        WallpaperManager.FLAG_SYSTEM
                )
            } else {
                wallpaperManager.setBitmap(bitmap)
            }
        }
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
                Log.d(tag, wallpaperManager.wallpaperInfo.settingsActivity)
                hasSettings = true
            }

            if (hasSettings) {
                val intent = Intent()
                        .setClassName(
                                wallpaperManager.wallpaperInfo.packageName,
                                wallpaperManager.wallpaperInfo.settingsActivity
                        )

                startActivity(intent)
                result.success(true)
            } else {
                result.error("noSettingsActivity", "The current live wallpaper does not have a settings screen", null)
            }
        } else {
            result.error("notALiveWallpaper", "The current wallpaper is not a live wallpaper", null)
        }
    }

    // Just a shortcut method instead of calling re.activity().star.. every time
    private fun startActivity(intent: Intent) {
        // Must call the activity()'s startActivity instead of context()'s
        // this is a solution to the https://stackoverflow.com/q/3918517/8608146 problem
        registrar.activity().startActivity(intent)
    }

    private fun sendWallpaperEvents(position: ArrayList<Float>) {
        Log.d(tag, "Sending a Wallpaper command")

        if (wallpaperManager.wallpaperInfo != null) {
            // Only send a command if it is a live wallpaper
            wallpaperManager.sendWallpaperCommand(
                    registrar.view().windowToken,
                    //if (event.action == MotionEvent.ACTION_UP)
                    //  WallpaperManager.COMMAND_TAP else
                    //  WallpaperManager.COMMAND_SECONDARY_TAP,
                    WallpaperManager.COMMAND_TAP,
                    position[0].toInt(), position[1].toInt(), 0, null
            )
        }

    }

    @RequiresApi(Build.VERSION_CODES.O_MR1)
    private fun getColors(): ArrayList<Int?>? {
        val data = wallpaperManager.getWallpaperColors(WallpaperManager.FLAG_SYSTEM)

        // Log.d(tag, "${data.primaryColor.red()} ${data.primaryColor.green()} ${data.primaryColor.blue()} ${data.primaryColor.alpha()}")
        val colors = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            arrayOf(data?.primaryColor?.toArgb(), data?.secondaryColor?.toArgb(), data?.tertiaryColor?.toArgb())
        } else {
            arrayOf()
        }
        return ArrayList(colors.asList())
    }

    private fun setWallpaperOffsets(args: ArrayList<Float>) {
        val position = args[0]
        var numPages = args[1]

        if (numPages <= 1) {
            numPages = 2F
        }

        val xOffset = position / (numPages - 1)
        wallpaperManager.setWallpaperOffsets(registrar.view().windowToken, xOffset, 0.0f)
    }

    // https://medium.com/flutter/flutter-platform-channels-ce7f540a104e
    inner class WallpaperListener : EventChannel.StreamHandler {
        var eventSink: EventChannel.EventSink? = null
        private lateinit var wallpaperEventReceiver: WallpaperEventReceiver
        private val intentFilter = IntentFilter()

        init {
            // This was deprecated by android because
            // It is not safe to set a wallpaper right after this event as it would cause a loop
            // And this is the only way to know if the wallpaper changed
            intentFilter.addAction(Intent.ACTION_WALLPAPER_CHANGED)
            // https://www.techotopia.com/index.php/Android_Broadcast_Intents_and_Broadcast_Receivers
        }

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
            if (eventSink != null) {
                wallpaperEventReceiver = WallpaperEventReceiver(eventSink!!)
                registerIfActive()
            }
        }

        override fun onCancel(arguments: Any?) {
            unregisterIfActive()
            eventSink = null
        }

        private fun registerIfActive() {
            if (eventSink == null) return
            applicationContext.registerReceiver(wallpaperEventReceiver, intentFilter)
        }

        private fun unregisterIfActive() {
            if (eventSink == null) return
            try {
                applicationContext.unregisterReceiver(wallpaperEventReceiver)
            } catch (e: Exception) {
            }
        }

    }


}

// Must be registered in the manifest file
// I registered it in the plugin's manifest file
class WallpaperEventReceiver() : BroadcastReceiver() {
    private lateinit var events: EventChannel.EventSink

    // This needs to be the syntax to avoid a build error in release mode
    constructor(events: EventChannel.EventSink) : this() {
        this.events = events
    }

    override fun onReceive(p0: Context, p1: Intent) {
        events.success(p1.action)
    }
}

// This needs to be added as a receiver in the app's android manifest file
// I added it to the plugin's manifest file which will get merged with any app that uses this
// A receiver to get which one was chosen from the wallpaper chooser
// TODO: Also the events from the wallpaper colors changed listener
// TODO: Also the events if the wallpaper has changed

class LauncherEventsReceiver : BroadcastReceiver() {
    private lateinit var events: EventChannel.EventSink

    init {
//        Log.d(tag, "INIT Events receiver")
        if (!::events.isInitialized) {
            events = globalPlugin.wallpaperListener.eventSink!!
        }
    }

    override fun onReceive(p0: Context, p1: Intent) {
        // https://stackoverflow.com/questions/9583230/what-is-the-purpose-of-intentsender#comment72280489_34314156
        // EXTRA_CHOSEN_COMPONENT requires API 22
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            Log.d(
                    tag,
                    p1.extras?.getParcelable<ComponentName>(Intent.EXTRA_CHOSEN_COMPONENT)!!.toString()
            )
            // Send a json object with event type and details instead of this
            events.success(p1.extras?.getParcelable<ComponentName>(Intent.EXTRA_CHOSEN_COMPONENT)!!.toString())
        }
        // Need to do this if registered somewhere in code
        // globalPlugin.applicationContext.unregisterReceiver(this)
    }
}

