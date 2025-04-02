import WidgetKit
import SwiftUI

// Modelo para los eventos guardados con campos adicionales
struct SavedEvent: Identifiable, Codable {
    let id: String
    let text: String
    let type: String?
    let room: String?
    let startTime: String?
    let endTime: String?
    let building: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        print("📱 Widget: placeholder called - initializing with empty data")
        return SimpleEntry(date: Date(), savedEvents: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("📱 Widget: getSnapshot called - fetching latest data")
        let savedEvents = fetchSavedEvents()
        print("📱 Widget: getSnapshot found \(savedEvents.count) saved events")
        let entry = SimpleEntry(date: Date(), savedEvents: savedEvents)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        print("📱 Widget: getTimeline called - generating new timeline")
        var entries: [SimpleEntry] = []

        let savedEvents = fetchSavedEvents()
        print("📱 Widget: getTimeline found \(savedEvents.count) saved events")
        if !savedEvents.isEmpty {
            print("📱 Widget: Found events: \(savedEvents.map { $0.text }.joined(separator: ", "))")
        } else {
            print("📱 Widget: No saved events found")
        }
        
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, savedEvents: savedEvents)
        entries.append(entry)

        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 2, to: currentDate)!
        print("📱 Widget: Timeline scheduled to update at \(nextUpdateDate)")
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    // Función para obtener los eventos guardados del storage compartido
    private func fetchSavedEvents() -> [SavedEvent] {
        print("📱 Widget: Attempting to fetch saved events from shared UserDefaults")
        
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.anonymous.test1.shared") else {
            print("📱 Widget: Failed to access shared UserDefaults")
            return []
        }
        
        // Log all keys in the shared defaults for debugging
        print("📱 Widget: All keys in shared defaults:")
        for key in sharedDefaults.dictionaryRepresentation().keys {
            print("- \(key)")
        }
        
        guard let savedEventsString = sharedDefaults.string(forKey: "savedTexts") else {
            print("📱 Widget: No saved events found in UserDefaults for key 'savedTexts'")
            return []
        }
        
        print("📱 Widget: Found savedEvents string with length: \(savedEventsString.count)")
        
        guard let data = savedEventsString.data(using: .utf8) else {
            print("📱 Widget: Failed to convert saved events string to data")
            return []
        }
        
        do {
            // Intentar decodificar usando el nuevo modelo
            let decodedEvents = try JSONDecoder().decode([SavedEvent].self, from: data)
            print("📱 Widget: Successfully decoded \(decodedEvents.count) saved events")
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
                    startTime: nil,
                    endTime: nil,
                    building: nil
                )}
                
                print("📱 Widget: Successfully decoded \(convertedEvents.count) events with old format")
                return convertedEvents
            } catch {
                print("📱 Widget: Error decoding with fallback model: \(error)")
                return []
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let savedEvents: [SavedEvent]
}

struct myWidgetEntryView : View {
    var entry: Provider.Entry
    
    // Función para formatear la hora (recortar a formato HH:MM)
    func formatTime(_ timeString: String?) -> String {
        guard let time = timeString else { return "" }
        // Si el formato es "HH:MM:SS", recortar a "HH:MM"
        if time.count >= 5 {
            return String(time.prefix(5))
        }
        return time
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Eventos de hoy")
                .font(.headline)
                .padding(.bottom, 2)
            
            if entry.savedEvents.isEmpty {
                Text("No hay eventos guardados")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(entry.savedEvents) { event in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.text)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    if let room = event.room, !room.isEmpty {
                                        Text(room)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                    
                                    if let start = event.startTime, let end = event.endTime {
                                        Text("\(formatTime(start)) - \(formatTime(end))")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let type = event.type, !type.isEmpty {
                                        Spacer()
                                        Text(type)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if let building = event.building, !building.isEmpty {
                                    Text(building)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Divider()
                                    .opacity(0.5)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}

@main
struct myWidget: Widget {
    let kind: String = "myWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            myWidgetEntryView(entry: entry)
                .padding()
                .background(Color(UIColor.systemBackground))
        }
        .configurationDisplayName("Mis Eventos")
        .description("Muestra tus eventos para hoy")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
