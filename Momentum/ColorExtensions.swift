import SwiftUI

extension Color {
    // Convert SwiftUI Color → hex string
    func toHex() -> String? {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components else { return nil }

        // Extract RGB components safely
        let r = Float(components[0])
        let g = Float(components.count > 1 ? components[1] : components[0])
        let b = Float(components.count > 2 ? components[2] : components[0])

        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }

    // Create Color from hex string
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    // Soft, aesthetic Momentum palette
    static let momentumPalette: [Color] = [
        Color(hex: "#A8DADC"), // soft teal
        Color(hex: "#F4A261"), // warm muted orange
        Color(hex: "#E9C46A"), // soft gold
        Color(hex: "#9B9ECE"), // gentle lavender
        Color(hex: "#F6BD60"), // mellow honey
        Color(hex: "#84A59D"), // sage gray-green
        Color(hex: "#F28482")  // dusty coral
    ]
}


