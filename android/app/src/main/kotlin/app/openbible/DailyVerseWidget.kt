package app.openbible

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Implementation of App Widget functionality.
 */
class DailyVerseWidget : AppWidgetProvider() {
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    companion object {
        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.daily_verse_widget)
            
            // Get data from HomeWidget plugin
            val widgetData = HomeWidgetPlugin.getData(context)
            val verseText = widgetData.getString("verseText", "For God so loved the world...")
            val verseReference = widgetData.getString("verseReference", "John 3:16")
            
            views.setTextViewText(R.id.verse_text, verseText)
            views.setTextViewText(R.id.verse_reference, verseReference)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
