//
//  Provider.swift
//  test1
//
//  Created by Guillermo Guevara on 03-04-25.
//


import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        print("📱 Widget: placeholder called - initializing with placeholder data")
        let currentDate = Date()
        let dayOfWeek = formatDayOfWeek(currentDate)
        let dayNumber = formatDayNumber(currentDate)
        
        return SimpleEntry(
            date: currentDate,
            dayOfWeek: dayOfWeek,
            dayNumber: dayNumber,
            savedEvents: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("📱 Widget: getSnapshot called - fetching latest data")
        let currentDate = Date()
        let dayOfWeek = formatDayOfWeek(currentDate)
        let dayNumber = formatDayNumber(currentDate)
        let savedEvents = fetchSavedEvents()
        
        let entry = SimpleEntry(
            date: currentDate,
            dayOfWeek: dayOfWeek,
            dayNumber: dayNumber,
            savedEvents: savedEvents
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        print("📱 Widget: getTimeline called - generating new timeline")
        let currentDate = Date()
        let dayOfWeek = formatDayOfWeek(currentDate)
        let dayNumber = formatDayNumber(currentDate)
        let savedEvents = fetchSavedEvents()
        
        print("📱 Widget: getTimeline found \(savedEvents.count) saved events")
        
        if !savedEvents.isEmpty {
            print("📱 Widget: Found events: \(savedEvents.map { $0.text }.joined(separator: ", "))")
        } else {
            print("📱 Widget: No saved events found")
        }
        
        let entry = SimpleEntry(
            date: currentDate,
            dayOfWeek: dayOfWeek,
            dayNumber: dayNumber,
            savedEvents: savedEvents
        )
        
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        print("📱 Widget: Timeline scheduled to update at \(nextUpdateDate)")
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    // Formateador para el día de la semana
    private func formatDayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEE"
        let dayOfWeek = formatter.string(from: date)
        return dayOfWeek.prefix(3).uppercased()
    }
    
    // Formateador para el número del día
    private func formatDayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // Función para obtener los eventos guardados del storage compartido
    private func fetchSavedEvents() -> [SavedEvent] {
        print("📱 Widget: Attempting to fetch saved events from shared UserDefaults")
        
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.anonymous.test1.shared") else {
            print("📱 Widget: Failed to access shared UserDefaults")
            return []
        }
        
        guard let savedEventsString = sharedDefaults.string(forKey: "savedTexts") else {
            print("📱 Widget: No saved events found in UserDefaults for key 'savedTexts'")
            return []
        }
        
        print("📱 Widget: Found savedEvents string with length: \(savedEventsString)")
        
        guard let data = savedEventsString.data(using: .utf8) else {
            print("📱 Widget: Failed to convert saved events string to data")
            return []
        }
        
        do {
            // Intentar decodificar usando el nuevo modelo
            let decodedEvents = try JSONDecoder().decode([SavedEvent].self, from: data)
            print("📱 Widget: Successfully decoded \(decodedEvents.count) saved events")
          print("😁 Wiooopdget: Successfully decoded \(decodedEvents) events with old format")

            return decodedEvents
        } catch {
            print("📱 Widget: Error decoding with new model, trying fallback: \(error)")
            
            // Fallback para mantener compatibilidad con el formato anterior
            do {
                // Estructura antigua para compatibilidad
                struct SavedText: Identifiable, Codable {
                    let id: String
                    let text: String
                }
                
                // Intentar decodificar con el modelo antiguo
                let oldFormatEvents = try JSONDecoder().decode([SavedText].self, from: data)
                
                // Convertir al nuevo formato
                let convertedEvents = oldFormatEvents.map { SavedEvent(
                    id: $0.id,
                    text: $0.text,
                    type: nil,
                    room: nil,
                    color: nil,
                    startTime: nil,
                    endTime: nil,
                    building: nil
                )}
                
                print("📱😁 Widget: Successfully decoded \(convertedEvents.count) events with old format")
                print("😁 Wiooopdget: Successfully decoded \(convertedEvents) events with old format")
                return convertedEvents
            } catch {
                print("📱 Widget: Error decoding with fallback model: \(error)")
                return []
            }
        }
    }
}
