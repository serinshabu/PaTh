package com.example.life_os

import android.Manifest
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "lifeos/device_features"
    private val notificationRequestCode = 4712
    private var notificationPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsageAccess" -> result.success(hasUsageAccess())
                    "requestUsageAccess" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "todayUsageMilliseconds" -> {
                        if (!hasUsageAccess()) {
                            result.error("usage_access_denied", "Usage access has not been granted.", null)
                        } else {
                            runCatching { todayUsageMilliseconds() }
                                .onSuccess { result.success(it) }
                                .onFailure { result.error("usage_read_failed", "Android could not read usage data.", null) }
                        }
                    }
                    "notificationsEnabled" -> result.success(notificationsEnabled())
                    "requestNotificationPermission" -> requestNotificationPermission(result)
                    "configureReminders" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args == null) {
                            result.error("invalid_preferences", "Reminder preferences are missing.", null)
                        } else {
                            LifeOsReminderScheduler.saveAndSchedule(applicationContext, args)
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun todayUsageMilliseconds(): Long {
        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val calendar = java.util.Calendar.getInstance().apply {
            set(java.util.Calendar.HOUR_OF_DAY, 0)
            set(java.util.Calendar.MINUTE, 0)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
        }
        val usage = manager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, calendar.timeInMillis, now)
        return usage.asSequence()
            .filter { it.packageName != packageName }
            .sumOf { it.totalTimeInForeground.coerceAtLeast(0L) }
    }

    private fun notificationsEnabled(): Boolean = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        manager.areNotificationsEnabled()
    } else true

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33 || checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) {
            result.success(notificationsEnabled())
            return
        }
        if (notificationPermissionResult != null) {
            result.error("permission_in_progress", "A notification permission request is already open.", null)
            return
        }
        notificationPermissionResult = result
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), notificationRequestCode)
    }

    @Deprecated("Deprecated in Android, retained for compatibility with Flutter activity callbacks")
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == notificationRequestCode) {
            notificationPermissionResult?.success(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
            notificationPermissionResult = null
        }
    }
}
