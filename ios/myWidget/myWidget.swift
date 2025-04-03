import WidgetKit
import SwiftUI

struct myWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Fecha en el lado izquierdo
            VStack(alignment: .center, spacing: 0) {
                Text(entry.dayOfWeek)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .gray)
                
                Text(entry.dayNumber)
                .font(.system(size: 62 ))
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .padding(.top, -5)
            }
            .padding(.top, 12)
            .frame(width: 50)
            
            // Event list
            VStack(spacing: 6) {
                if entry.savedEvents.isEmpty {
                    Text("No hay eventos para hoy")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                } else {
                    // Mostrar solo hasta 3 eventos para asegurar que caben
                    let limitedEvents = Array(entry.savedEvents.prefix(3))
                    
                    ForEach(0..<limitedEvents.count, id: \.self) { index in
                        let event = limitedEvents[index]
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(myWidgetUtils.hexColor(event.color))
                                .onAppear {
                                    print("🎨 Evento \(index): \(event.text) - Color: \(event.color ?? "ninguno")")
                                }
                            
                            HStack {
                                // Tiempo
                                if let start = event.startTime {
                                    Text(myWidgetUtils.formatTime(start))
                                        .foregroundColor(.black)
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                
                                // Título del evento
                                Text(event.text)
                                    .foregroundColor(.black)
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                // Sala
                                if let room = event.room, !room.isEmpty {
                                    Text(room)
                                        .foregroundColor(.black)
                                        .font(.system(size: 11, weight: .semibold))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                        }
                    }
                    
                    // Indicador de más eventos
                    if entry.savedEvents.count > limitedEvents.count {
                        Text("+ \(entry.savedEvents.count - limitedEvents.count) más...")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 8)
                            .padding(.top, 2)
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 10)
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
