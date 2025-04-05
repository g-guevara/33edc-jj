package com.anonymous.test1

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.util.Log
import org.json.JSONArray
import org.json.JSONException

class MyAppWidget : AppWidgetProvider() {
    private val TAG = "MyAppWidget"

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d(TAG, "onUpdate llamado para widget IDs: ${appWidgetIds.joinToString()}")
        
        // Actualiza todos los widgets
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "onEnabled: Widget habilitado por primera vez")
    }
    
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "onDisabled: Todos los widgets fueron eliminados")
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive: Acción recibida: ${intent.action}")
        super.onReceive(context, intent)
    }

    companion object {
        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            Log.d("MyAppWidget", "Actualizando widget ID: $appWidgetId")
            
            // Construye la vista del widget
            val views = RemoteViews(context.packageName, R.layout.app_widget)
            
            // Obtiene los eventos guardados
            val savedEventsJson = getSavedEvents(context)
            Log.d("MyAppWidget", "Eventos recuperados: $savedEventsJson")
            
            val eventListBuilder = StringBuilder()
            
            try {
                val eventsArray = JSONArray(savedEventsJson)
                Log.d("MyAppWidget", "Número de eventos guardados: ${eventsArray.length()}")
                
                if (eventsArray.length() == 0) {
                    views.setTextViewText(R.id.text_list, "No hay eventos para hoy")
                    Log.d("MyAppWidget", "Configurando texto del widget: 'No hay eventos para hoy'")
                } else {
                    // Limita a mostrar máximo 3 eventos
                    val limit = minOf(eventsArray.length(), 3)
                    
                    for (i in 0 until limit) {
                        val eventObj = eventsArray.getJSONObject(i)
                        
                        // Intenta obtener los campos del evento con manejo de errores
                        val eventText = eventObj.optString("text", "Evento sin nombre")
                        
                        // Intenta obtener sala, hora inicio y fin (con valores por defecto)
                        val eventRoom = eventObj.optString("room", "")
                        val startTime = eventObj.optString("startTime", "")
                        val endTime = eventObj.optString("endTime", "")
                        
                        // Construye la información del evento con lo que esté disponible
                        eventListBuilder.append(eventText)
                        
                        // Añade información de sala y hora si están disponibles
                        val details = mutableListOf<String>()
                        if (eventRoom.isNotEmpty()) details.add(eventRoom)
                        if (startTime.isNotEmpty() && endTime.isNotEmpty()) {
                            details.add("${startTime.substring(0, minOf(5, startTime.length))} - ${endTime.substring(0, minOf(5, endTime.length))}")
                        }
                        
                        if (details.isNotEmpty()) {
                            eventListBuilder.append(" (").append(details.joinToString(", ")).append(")")
                        }
                        
                        eventListBuilder.append("\n\n")
                        Log.d("MyAppWidget", "Añadiendo evento al widget: $eventText")
                    }
                    
                    if (eventsArray.length() > 3) {
                        eventListBuilder.append("+ ").append(eventsArray.length() - 3).append(" más...")
                        Log.d("MyAppWidget", "Añadiendo '+ ${eventsArray.length() - 3} más...' al widget")
                    }
                    
                    val finalText = eventListBuilder.toString().trim()
                    views.setTextViewText(R.id.text_list, finalText)
                    Log.d("MyAppWidget", "Configurando texto del widget: '$finalText'")
                }
            } catch (e: JSONException) {
                Log.e("MyAppWidget", "Error al analizar JSON: ${e.message}", e)
                views.setTextViewText(R.id.text_list, "Error al cargar eventos")
            }
            
            // Actualiza el widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
            Log.d("MyAppWidget", "Widget ID $appWidgetId actualizado exitosamente")
        }
        
        private fun getSavedEvents(context: Context): String {
            val sharedPreferences = context.getSharedPreferences(
                    "com.anonymous.test1.shared", Context.MODE_PRIVATE)
            val savedEvents = sharedPreferences.getString("savedTexts", "[]") ?: "[]"
            Log.d("MyAppWidget", "Eventos recuperados de SharedPreferences: $savedEvents")
            return savedEvents
        }
    }
}