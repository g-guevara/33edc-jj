import WidgetKit
import SwiftUI

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
    
    // Función para convertir un hex string a Color
    func hexColor(_ hexString: String?) -> Color {
        // Valor de debug para ver lo que recibimos
        print("🎨 Procesando color: \(hexString ?? "nil")")
        
        // Si no hay color o es inválido, usar un color por defecto
        guard let hexString = hexString, hexString.count >= 4 else {
            print("⚠️ Hex inválido, usando color por defecto")
            return Color.blue
        }
        
        // Extraer el hexadecimal sin el # (si existe)
        let hex = hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString
        print("🔍 Hex procesado: \(hex)")
        
        // Extraer los componentes RGB
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: Double
        switch hex.count {
        case 3: // RGB (12-bit)
            r = Double((int >> 8) & 0xF) / 15.0
            g = Double((int >> 4) & 0xF) / 15.0
            b = Double(int & 0xF) / 15.0
            print("🧩 RGB (formato corto): \(r), \(g), \(b)")
        case 6: // RRGGBB (24-bit)
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            print("🧩 RGB (formato largo): \(r), \(g), \(b)")
        default:
            print("⚠️ Formato hex desconocido, usando color por defecto")
            return Color.blue
        }
        
        return Color(red: r, green: g, blue: b)
    }
    
    // Función de colores predeterminados como respaldo
    func defaultEventColor(index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.4, green: 0.8, blue: 0.6), // Verde claro
            Color(red: 0.4, green: 0.7, blue: 0.9), // Azul claro
            Color(red: 0.9, green: 0.7, blue: 0.4), // Naranja claro
            Color(red: 0.8, green: 0.5, blue: 0.8)  // Morado claro
        ]
        return colors[index % colors.count]
    }

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
                                .fill(hexColor(event.color))
                                .onAppear {
                                    print("🎨 Evento \(index): \(event.text) - Color: \(event.color ?? "ninguno")")
                                }
                            
                            HStack {
                                // Tiempo
                                if let start = event.startTime {
                                    Text(formatTime(start))
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
