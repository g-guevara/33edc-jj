import WidgetKit
import SwiftUI

// Modelo para los textos guardados
struct SavedText: Identifiable, Codable {
    let id: String
    let text: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        print("📱 Widget: placeholder called - initializing with empty data")
        return SimpleEntry(date: Date(), savedTexts: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("📱 Widget: getSnapshot called - fetching latest data")
        let savedTexts = fetchSavedTexts()
        print("📱 Widget: getSnapshot found \(savedTexts.count) saved events")
        let entry = SimpleEntry(date: Date(), savedTexts: savedTexts)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        print("📱 Widget: getTimeline called - generating new timeline")
        var entries: [SimpleEntry] = []

        let savedTexts = fetchSavedTexts()
        print("📱 Widget: getTimeline found \(savedTexts.count) saved events")
        if !savedTexts.isEmpty {
            print("📱 Widget: Found events: \(savedTexts.map { $0.text }.joined(separator: ", "))")
        } else {
            print("📱 Widget: No saved events found")
        }
        
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, savedTexts: savedTexts)
        entries.append(entry)

        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 2, to: currentDate)!
        print("📱 Widget: Timeline scheduled to update at \(nextUpdateDate)")
        let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
        completion(timeline)
    }
    
    // Función para obtener los textos guardados del storage compartido
    private func fetchSavedTexts() -> [SavedText] {
        print("📱 Widget: Attempting to fetch saved texts from shared UserDefaults")
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.7io-locale.shared") else {
            print("📱 Widget: Failed to access shared UserDefaults")
            return []
        }
        
        guard let savedTextsString = sharedDefaults.string(forKey: "savedTexts") else {
            print("📱 Widget: No saved texts found in UserDefaults")
            return []
        }
        
        guard let data = savedTextsString.data(using: .utf8) else {
            print("📱 Widget: Failed to convert saved texts string to data")
            return []
        }
        
        do {
            let decodedTexts = try JSONDecoder().decode([SavedText].self, from: data)
            print("📱 Widget: Successfully decoded \(decodedTexts.count) saved texts")
            return decodedTexts
        } catch {
            print("📱 Widget: Error decoding saved texts: \(error)")
            return []
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let savedTexts: [SavedText]
}

struct myWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Eventos de hoy:")
                .font(.headline)
                .padding(.bottom, 4)
            
            if entry.savedTexts.isEmpty {
                Text("No hay eventos guardados")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                // Mostrar solo los eventos, bien simple como pediste
                ForEach(entry.savedTexts) { text in
                    Text(text.text)
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.vertical, 2)
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
