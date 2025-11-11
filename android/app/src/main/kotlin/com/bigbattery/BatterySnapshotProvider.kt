package com.bigbattery

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.text.format.DateFormat
import android.view.View
import java.util.Date
import kotlin.math.roundToInt

data class BatterySnapshot(
    val level: Int,
    val statusText: String,
    val updatedText: String,
    val isCharging: Boolean,
    val timestamp: Long
) {
    val levelText: String get() = "$level%"
    val chargeVisibility: Int get() = if (isCharging) View.VISIBLE else View.GONE
}

object BatterySnapshotProvider {

    fun read(context: Context): BatterySnapshot {
        val intent = registerStickyBatteryIntent(context)
        val manager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager

        val capacity = manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        val fallbackLevel = intent?.let {
            val level = it.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale = it.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            if (level >= 0 && scale > 0) ((level / scale.toFloat()) * 100).roundToInt() else -1
        } ?: -1

        val batteryLevel = capacity.takeIf { it in 0..100 } ?: fallbackLevel.coerceIn(0, 100)
        val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val plugged = intent?.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) ?: 0
        val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL ||
            plugged != 0

        val statusText = when {
            isCharging && batteryLevel >= 100 -> "충전 완료"
            isCharging -> "충전 중"
            batteryLevel <= 20 -> "배터리 낮음"
            else -> "배터리 사용 중"
        }

        val updatedAt = DateFormat.format("HH:mm", Date()).toString()
        return BatterySnapshot(
            level = batteryLevel,
            statusText = statusText,
            updatedText = "$updatedAt 업데이트",
            isCharging = isCharging,
            timestamp = System.currentTimeMillis()
        )
    }

    private fun registerStickyBatteryIntent(context: Context): Intent? {
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(null, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            context.registerReceiver(null, filter)
        }
    }
}
