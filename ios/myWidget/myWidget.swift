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
    let dayOfWeek: String
    let dayNumber: String
    let savedEvents: [SavedEvent]
}

struct myWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    // Función para formatear la hora (recortar a formato HH:MM)
    func formatTime(_ timeString: String?) -> String {
        guard let time = timeString else { return "" }
        // Si el formato es "HH:MM:SS", recortar a "HH:MM"
        if time.count >= 5 {
            return String(time.prefix(5))
        }
        return time
    }
    
    // Función para seleccionar el color para cada evento
    func eventColor(index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.4, green: 0.8, blue: 0.6), // Verde claro
            Color(red: 0.4, green: 0.7, blue: 0.9), // Azul claro
            Color(red: 0.9, green: 0.7, blue: 0.4), // Naranja claro
            Color(red: 0.8, green: 0.5, blue: 0.8)  // Morado claro
        ]
        return colors[index % colors.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Day header
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(entry.dayOfWeek)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? .white : .gray)
                    
                    Text(entry.dayNumber)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .padding(.top, -5)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
            }
            
            Spacer()
            
            // Event list
            VStack(spacing: 8) {
                if entry.savedEvents.isEmpty {
                    Text("No hay eventos para hoy")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                } else {
                    // Mostrar solo hasta 4 eventos para asegurar que caben
                    let limitedEvents = Array(entry.savedEvents.prefix(3))
                    
                    ForEach(0..<limitedEvents.count, id: \.self) { index in
                        let event = limitedEvents[index]
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(eventColor(index: index))
                            
                            HStack {
                                // Tiempo
                                if let start = event.startTime {
                                    Text(formatTime(start))
                                        .foregroundColor(.black)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                
                                // Título del evento
                                Text(event.text)
                                    .foregroundColor(.black)
                                    .font(.system(size: 14, weight: .semibold))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                // Sala
                                if let room = event.room, !room.isEmpty {
                                    Text(room)
                                        .foregroundColor(.black)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Indicador de más eventos
                    if entry.savedEvents.count > limitedEvents.count {
                        Text("+ \(entry.savedEvents.count - limitedEvents.count) más...")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 12)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

@main
struct myWidget: Widget {
    let kind: String = "myWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            myWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Mis Eventos")
        .description("Muestra tus eventos para hoy")
        .supportedFamilies([.systemMedium])
    }
}
