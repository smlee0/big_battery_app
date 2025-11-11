// Flutter 엔진과 안드로이드 배터리 브로드캐스트를 연결하는 Activity.
package com.bigbattery

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * 배터리 EventChannel 을 등록하고 Flutter 쪽으로 스냅샷을 전달하는 기본 Activity.
 */
class MainActivity : FlutterActivity() {

    companion object {
        // Flutter 쪽 EventChannel과 동일한 식별자
        private const val BATTERY_EVENT_CHANNEL =
            "com.bigbattery/battery_updates"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            BATTERY_EVENT_CHANNEL
        ).setStreamHandler(BatteryEventsStreamHandler(applicationContext))
    }
}

/**
 * ACTION_BATTERY_CHANGED 브로드캐스트를 수신해 EventChannel 로 전달한다.
 */
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
