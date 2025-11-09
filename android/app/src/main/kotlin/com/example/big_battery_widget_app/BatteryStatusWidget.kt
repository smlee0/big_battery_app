package com.example.big_battery_widget_app

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

class BatteryStatusWidget : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_POWER_CONNECTED,
            Intent.ACTION_POWER_DISCONNECTED,
            AppWidgetManager.ACTION_APPWIDGET_UPDATE -> {
                registerBatteryReceiver(context)
                BatteryWidgetUpdater.updateAllWidgets(context)
            }
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        registerBatteryReceiver(context)
        BatteryWidgetUpdater.updateAllWidgets(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        unregisterBatteryReceiver(context)
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

        private fun registerBatteryReceiver(context: Context) {
            if (batteryChangeReceiver != null) return
            val appContext = context.applicationContext
            val receiver = object : BroadcastReceiver() {
                override fun onReceive(ctx: Context?, intent: Intent?) {
                    if (intent?.action == Intent.ACTION_BATTERY_CHANGED) {
                        BatteryWidgetUpdater.updateAllWidgets(appContext)
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
    }
}

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
