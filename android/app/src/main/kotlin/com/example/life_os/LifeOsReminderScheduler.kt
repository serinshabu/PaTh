package com.example.life_os

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONObject
import java.util.Calendar

internal object LifeOsReminderScheduler {
    private const val preferencesFile = "life_os_device_preferences"
    private const val preferencesKey = "reminders_json"
    private const val channelId = "life_os_reminders"
    private const val notificationBaseId = 7100

    fun saveAndSchedule(context: Context, values: Map<*, *>) {
        val json = JSONObject()
        values.forEach { (key, value) -> if (key is String) json.put(key, value) }
        context.getSharedPreferences(preferencesFile, Context.MODE_PRIVATE)
            .edit().putString(preferencesKey, json.toString()).apply()
        ensureNotificationChannel(context)
        cancelAll(context)
        scheduleAll(context, json)
    }

    fun scheduleAll(context: Context) {
        val encoded = context.getSharedPreferences(preferencesFile, Context.MODE_PRIVATE)
            .getString(preferencesKey, null) ?: return
        val json = runCatching { JSONObject(encoded) }.getOrNull() ?: return
        scheduleAll(context, json)
    }

    private fun scheduleAll(context: Context, settings: JSONObject) {
        val reminders = listOf(
            Reminder(0, "habitEnabled", "habitHour", "habitMinute", "A moment for your habits"),
            Reminder(1, "taskEnabled", "taskHour", "taskMinute", "Check in with your tasks"),
            Reminder(2, "reviewEnabled", "reviewHour", "reviewMinute", "Your optional evening review is here"),
            Reminder(3, "planningEnabled", "planningHour", "planningMinute", "A gentle moment to plan your day"),
        )
        reminders.filter { settings.optBoolean(it.enabledKey, false) }.forEach { scheduleOne(context, settings, it) }
    }

    private fun scheduleOne(context: Context, settings: JSONObject, reminder: Reminder) {
        val hour = settings.optInt(reminder.hourKey, 20).coerceIn(0, 23)
        val minute = settings.optInt(reminder.minuteKey, 0).coerceIn(0, 59)
        val quiet = settings.optBoolean("quietHoursEnabled", false)
        val quietStart = settings.optInt("quietStartHour", 22).coerceIn(0, 23)
        val quietEnd = settings.optInt("quietEndHour", 7).coerceIn(0, 23)
        if (quiet && inQuietHours(hour, quietStart, quietEnd)) return

        val now = Calendar.getInstance()
        val next = (now.clone() as Calendar).apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (!after(now)) add(Calendar.DAY_OF_YEAR, 1)
        }
        val intent = Intent(context, LifeOsReminderReceiver::class.java).apply {
            action = "com.example.life_os.REMINDER.${reminder.id}"
            putExtra("reminder_id", reminder.id)
            putExtra("reminder_title", reminder.title)
        }
        val pending = PendingIntent.getBroadcast(
            context,
            reminder.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next.timeInMillis, pending)
        } else {
            @Suppress("DEPRECATION")
            alarm.set(AlarmManager.RTC_WAKEUP, next.timeInMillis, pending)
        }
    }

    private fun cancelAll(context: Context) {
        val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (id in 0..3) {
            val intent = Intent(context, LifeOsReminderReceiver::class.java).apply {
                action = "com.example.life_os.REMINDER.$id"
            }
            val pending = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
            )
            if (pending != null) alarm.cancel(pending)
            pending?.cancel()
        }
    }

    fun deliver(context: Context, id: Int, title: String) {
        ensureNotificationChannel(context)
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && !manager.areNotificationsEnabled()) return
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val contentIntent = launchIntent?.let {
            PendingIntent.getActivity(
                context,
                notificationBaseId + id,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        val notification = builder
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle("PaTh")
            .setContentText(title)
            .setAutoCancel(true)
            .setContentIntent(contentIntent)
            .build()
        manager.notify(notificationBaseId + id, notification)
    }

    fun reschedule(context: Context, id: Int) {
        val encoded = context.getSharedPreferences(preferencesFile, Context.MODE_PRIVATE)
            .getString(preferencesKey, null) ?: return
        val settings = runCatching { JSONObject(encoded) }.getOrNull() ?: return
        val reminders = listOf(
            Reminder(0, "habitEnabled", "habitHour", "habitMinute", "A moment for your habits"),
            Reminder(1, "taskEnabled", "taskHour", "taskMinute", "Check in with your tasks"),
            Reminder(2, "reviewEnabled", "reviewHour", "reviewMinute", "Your optional evening review is here"),
            Reminder(3, "planningEnabled", "planningHour", "planningMinute", "A gentle moment to plan your day"),
        )
        reminders.firstOrNull { it.id == id }?.let { reminder ->
            if (settings.optBoolean(reminder.enabledKey, false)) scheduleOne(context, settings, reminder)
        }
    }

    private fun ensureNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(
                NotificationChannel(channelId, "PaTh reminders", NotificationManager.IMPORTANCE_DEFAULT)
                    .apply { description = "Private local reminders selected in PaTh settings." },
            )
        }
    }

    private fun inQuietHours(hour: Int, start: Int, end: Int): Boolean {
        if (start == end) return true
        return if (start < end) hour >= start && hour < end else hour >= start || hour < end
    }

    private data class Reminder(
        val id: Int,
        val enabledKey: String,
        val hourKey: String,
        val minuteKey: String,
        val title: String,
    )
}

class LifeOsReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val id = intent.getIntExtra("reminder_id", -1)
        if (id !in 0..3) return
        LifeOsReminderScheduler.deliver(
            context,
            id,
            intent.getStringExtra("reminder_title") ?: "Your PaTh reminder is here",
        )
        LifeOsReminderScheduler.reschedule(context, id)
    }
}

class LifeOsReminderBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            intent.action == Intent.ACTION_TIME_CHANGED ||
            intent.action == Intent.ACTION_TIMEZONE_CHANGED ||
            intent.action == Intent.ACTION_DATE_CHANGED
        ) {
            LifeOsReminderScheduler.scheduleAll(context)
        }
    }
}
