package com.example.ripple

import android.app.role.RoleManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.LauncherApps
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.UserManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val worker = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var packageReceiver: BroadcastReceiver? = null

    override fun getTransparencyMode(): TransparencyMode = TransparencyMode.transparent

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler { call, result -> handleCall(call, result) }
        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                eventSink = events
                registerPackageReceiver()
                NotificationCounterService.listener = { counts -> emit(mapOf("type" to "notifications", "counts" to counts)) }
                NotificationCounterService.publishCurrent()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                NotificationCounterService.listener = null
                unregisterPackageReceiver()
            }
        })
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.hasCategory(Intent.CATEGORY_HOME)) {
            emit(mapOf("type" to "home"))
        }
    }

    override fun onDestroy() {
        unregisterPackageReceiver()
        worker.shutdown()
        super.onDestroy()
    }

    private fun handleCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getApps" -> worker.execute {
                val apps = loadApps(call.argument<Int>("iconSize") ?: 144)
                mainHandler.post { result.success(apps) }
            }
            "launch" -> result.success(launch(call.argument<String>("package") ?: ""))
            "openAppInfo" -> {
                startSafely(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + call.argument<String>("package"))))
                result.success(null)
            }
            "uninstall" -> {
                startSafely(Intent(Intent.ACTION_DELETE, Uri.parse("package:" + call.argument<String>("package"))))
                result.success(null)
            }
            "isDefaultLauncher" -> result.success(isDefaultLauncher())
            "requestDefaultLauncher" -> {
                requestDefaultLauncher()
                result.success(null)
            }
            "hasNotificationAccess" -> result.success(hasNotificationAccess())
            "openNotificationAccess" -> {
                openNotificationAccess()
                result.success(null)
            }
            "openRippleAppInfo" -> {
                startSafely(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")))
                result.success(null)
            }
            "expandNotifications" -> {
                expandNotifications()
                result.success(null)
            }
            "openWallpaperPicker" -> {
                startSafely(Intent.createChooser(Intent(Intent.ACTION_SET_WALLPAPER), null))
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun loadApps(iconSize: Int): List<Map<String, Any>> {
        val launcherApps = getSystemService(Context.LAUNCHER_APPS_SERVICE) as LauncherApps
        val userManager = getSystemService(Context.USER_SERVICE) as UserManager
        return userManager.userProfiles
            .flatMap { profile -> launcherApps.getActivityList(null, profile) }
            .filter { it.applicationInfo.packageName != packageName }
            .distinctBy { it.applicationInfo.packageName }
            .map { activity ->
                mapOf(
                    "package" to activity.applicationInfo.packageName,
                    "label" to activity.label.toString(),
                    "icon" to drawableToPng(activity.getBadgedIcon(0), iconSize),
                )
            }
    }

    private fun drawableToPng(drawable: Drawable, size: Int): ByteArray {
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(canvas)
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        bitmap.recycle()
        return stream.toByteArray()
    }

    private fun launch(packageName: String): Boolean {
        val intent = packageManager.getLaunchIntentForPackage(packageName) ?: return false
        return startSafely(intent)
    }

    private fun startSafely(intent: Intent): Boolean {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return try {
            startActivity(intent)
            true
        } catch (exception: Exception) {
            false
        }
    }

    private fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val resolved = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolved?.activityInfo?.packageName == packageName
    }

    private fun requestDefaultLauncher() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            if (roleManager.isRoleAvailable(RoleManager.ROLE_HOME) && !roleManager.isRoleHeld(RoleManager.ROLE_HOME)) {
                startActivityForResult(roleManager.createRequestRoleIntent(RoleManager.ROLE_HOME), 0)
                return
            }
        }
        startSafely(Intent(Settings.ACTION_HOME_SETTINGS))
    }

    private fun hasNotificationAccess(): Boolean {
        val enabled = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: return false
        val component = ComponentName(this, NotificationCounterService::class.java).flattenToString()
        return enabled.split(":").contains(component)
    }

    private fun openNotificationAccess() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val component = ComponentName(this, NotificationCounterService::class.java).flattenToString()
            val detail = Intent(Settings.ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS)
                .putExtra(Settings.EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME, component)
            if (startSafely(detail)) return
        }
        startSafely(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
    }

    @Suppress("WrongConstant")
    private fun expandNotifications() {
        try {
            val service = getSystemService("statusbar")
            Class.forName("android.app.StatusBarManager").getMethod("expandNotificationsPanel").invoke(service)
        } catch (exception: Exception) {
            return
        }
    }

    private fun registerPackageReceiver() {
        if (packageReceiver != null) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                emit(mapOf("type" to "packagesChanged"))
            }
        }
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addAction(Intent.ACTION_PACKAGE_CHANGED)
            addAction(Intent.ACTION_PACKAGE_REPLACED)
            addDataScheme("package")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
        packageReceiver = receiver
    }

    private fun unregisterPackageReceiver() {
        packageReceiver?.let { unregisterReceiver(it) }
        packageReceiver = null
    }

    private fun emit(event: Map<String, Any>) {
        mainHandler.post { eventSink?.success(event) }
    }

    companion object {
        private const val METHOD_CHANNEL = "ripple/device"
        private const val EVENT_CHANNEL = "ripple/device_events"
    }
}
