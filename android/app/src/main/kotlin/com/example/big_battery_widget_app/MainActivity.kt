package com.example.big_battery_widget_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val BATTERY_EVENT_CHANNEL =
            "com.example.big_battery_widget_app/battery_updates"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BATTERY_EVENT_CHANNEL
        ).setStreamHandler(BatteryEventsStreamHandler(applicationContext))
    }
}

private class BatteryEventsStreamHandler(
    private val context: Context
) : EventChannel.StreamHandler {

    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        if (receiver != null) {
            sendSnapshot(events)
            return
        }
        val appContext = context.applicationContext
        receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                sendSnapshot(events)
            }
        }
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            appContext.registerReceiver(
                receiver,
                filter,
                Context.RECEIVER_NOT_EXPORTED
            )
        } else {
            @Suppress("DEPRECATION")
            appContext.registerReceiver(receiver, filter)
        }
        sendSnapshot(events)
    }

    override fun onCancel(arguments: Any?) {
        receiver?.let {
            runCatching { context.unregisterReceiver(it) }
        }
        receiver = null
    }

    private fun sendSnapshot(events: EventChannel.EventSink) {
        val snapshot = BatterySnapshotProvider.read(context)
        events.success(
            mapOf(
                "level" to snapshot.level,
                "statusText" to snapshot.statusText,
                "isCharging" to snapshot.isCharging,
                "timestamp" to snapshot.timestamp
            )
        )
    }
}
