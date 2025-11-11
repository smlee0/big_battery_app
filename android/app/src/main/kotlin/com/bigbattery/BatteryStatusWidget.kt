// 홈 화면 배터리 위젯 업데이트/스케줄링을 담당하는 AppWidgetProvider.
package com.bigbattery

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import kotlin.math.ceil
import kotlin.math.max

/**
 * 시스템 브로드캐스트를 감지해 RemoteViews 를 갱신하는 배터리 위젯 프로바이더.
 */
class BatteryStatusWidget : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_REFRESH_WIDGET -> {
                BatteryWidgetUpdater.updateAllWidgets(context)
                scheduleNextUpdate(context)
            }
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_POWER_CONNECTED,
            Intent.ACTION_POWER_DISCONNECTED,
            AppWidgetManager.ACTION_APPWIDGET_UPDATE -> {
                registerBatteryReceiver(context)
                BatteryWidgetUpdater.updateAllWidgets(context)
                scheduleNextUpdate(context)
            }
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        registerBatteryReceiver(context)
        scheduleNextUpdate(context)
        BatteryWidgetUpdater.updateAllWidgets(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        unregisterBatteryReceiver(context)
        cancelScheduledUpdate(context)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        BatteryWidgetUpdater.updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        BatteryWidgetUpdater.updateWidgets(context, appWidgetManager, intArrayOf(appWidgetId))
    }

    companion object {
        private var batteryChangeReceiver: BroadcastReceiver? = null
        // 홈 위젯 갱신을 강제로 트리거하는 커스텀 액션
        private const val ACTION_REFRESH_WIDGET =
            "com.bigbattery.ACTION_REFRESH_WIDGET"
        private const val UPDATE_INTERVAL_MS = 5 * 60 * 1000L

        private fun registerBatteryReceiver(context: Context) {
            if (batteryChangeReceiver != null) return
            val appContext = context.applicationContext
            val receiver = object : BroadcastReceiver() {
                override fun onReceive(ctx: Context?, intent: Intent?) {
                    if (intent?.action == Intent.ACTION_BATTERY_CHANGED) {
                        BatteryWidgetUpdater.updateAllWidgets(appContext)
                        scheduleNextUpdate(appContext)
                    }
                }
            }
            val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                appContext.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                @Suppress("DEPRECATION")
                appContext.registerReceiver(receiver, filter)
            }
            batteryChangeReceiver = receiver
        }

        private fun unregisterBatteryReceiver(context: Context) {
            val appContext = context.applicationContext
            batteryChangeReceiver?.let {
                runCatching { appContext.unregisterReceiver(it) }
                batteryChangeReceiver = null
            }
        }

        internal fun refreshPendingIntent(context: Context): PendingIntent {
            return createRefreshPendingIntent(
                context,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )!!
        }

        private fun scheduleNextUpdate(context: Context) {
            val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val triggerAt = System.currentTimeMillis() + UPDATE_INTERVAL_MS
            val pendingIntent = refreshPendingIntent(context)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    triggerAt,
                    pendingIntent
                )
            } else {
                alarmManager.set(
                    AlarmManager.RTC_WAKEUP,
                    triggerAt,
                    pendingIntent
                )
            }
        }

        private fun cancelScheduledUpdate(context: Context) {
            val alarmManager =
                context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val pendingIntent = createRefreshPendingIntent(
                context,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_NO_CREATE
            ) ?: return
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }

        private fun createRefreshPendingIntent(
            context: Context,
            flags: Int
        ): PendingIntent? {
            val intent = Intent(context, BatteryStatusWidget::class.java).apply {
                action = ACTION_REFRESH_WIDGET
            }
            return PendingIntent.getBroadcast(context, 0, intent, flags)
        }
    }
}

/**
 * RemoteViews 를 실제로 구성해서 AppWidgetManager 에 적용하는 헬퍼.
 */
object BatteryWidgetUpdater {

    fun updateAllWidgets(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val component = ComponentName(context, BatteryStatusWidget::class.java)
        val ids = manager.getAppWidgetIds(component)
        if (ids.isNotEmpty()) {
            updateWidgets(context, manager, ids)
        }
    }

    fun updateWidgets(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val snapshot = BatterySnapshotProvider.read(context)
        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val columns = resolveColumnCount(options)
            val isCompact = columns <= 1
            val valueTextSize = if (isCompact) 46f else 40f
            val symbolTextSize = if (isCompact) 26f else 22f
            val backgroundRes = resolveBackground(snapshot.level)
            val views = RemoteViews(context.packageName, R.layout.widget_battery_meter).apply {
                setTextViewText(
                    R.id.widgetPercentageValue,
                    snapshot.level.toString()
                )
                setTextViewTextSize(
                    R.id.widgetPercentageValue,
                    TypedValue.COMPLEX_UNIT_SP,
                    valueTextSize
                )
                setTextViewText(R.id.widgetPercentageSymbol, "%")
                setTextViewTextSize(
                    R.id.widgetPercentageSymbol,
                    TypedValue.COMPLEX_UNIT_SP,
                    symbolTextSize
                )
                setInt(R.id.widgetProgress, "setProgress", snapshot.level)
                setInt(R.id.widgetProgress, "setMax", 100)
                setViewVisibility(
                    R.id.widgetProgress,
                    if (isCompact) View.GONE else View.VISIBLE
                )
                setInt(R.id.widgetRoot, "setBackgroundResource", backgroundRes)
                val badgeVisibility = if (snapshot.isCharging) View.VISIBLE else View.GONE
                setViewVisibility(R.id.widgetChargeBadge, badgeVisibility)
                if (snapshot.isCharging) {
                    setImageViewResource(R.id.widgetChargeBadge, R.drawable.widget_charge_icon)
                    setContentDescription(
                        R.id.widgetChargeBadge,
                        context.getString(R.string.widget_charging_icon)
                    )
                }
                setOnClickPendingIntent(
                    R.id.widgetRefreshButton,
                    BatteryStatusWidget.refreshPendingIntent(context)
                )
            }
            val launchIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                widgetId,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widgetRoot, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun resolveColumnCount(options: Bundle?): Int {
        val minWidth = options?.getInt(
            AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH,
            DEFAULT_MIN_WIDTH_DP
        ) ?: DEFAULT_MIN_WIDTH_DP
        return calculateCells(minWidth)
    }

    private fun calculateCells(sizeDp: Int): Int {
        if (sizeDp <= 0) return 1
        val cellSize = 70
        val padding = 30
        return max(1, ceil((sizeDp + padding) / cellSize.toDouble()).toInt())
    }

    private fun resolveBackground(level: Int): Int {
        return when {
            level >= 51 -> R.drawable.widget_bg_high
            level >= 21 -> R.drawable.widget_bg_medium
            else -> R.drawable.widget_bg_low
        }
    }

    private const val DEFAULT_MIN_WIDTH_DP = 140
}
