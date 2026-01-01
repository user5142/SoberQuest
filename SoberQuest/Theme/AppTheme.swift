import SwiftUI

// MARK: - SoberQuest Dark Fantasy Theme
// Inspired by RPG aesthetics with warm accents on deep dark backgrounds

struct AppTheme {
    
    // MARK: - Background Colors
    static let background = Color(hex: "0D0D0D")           // Deep black
    static let backgroundSecondary = Color(hex: "1A1A1A")  // Slightly lighter black
    static let cardBackground = Color(hex: "F5E6D3")       // Warm cream/parchment
    static let cardBackgroundDark = Color(hex: "2A2A2A")   // Dark card variant
    
    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9A9A9A")
    static let textOnCard = Color(hex: "2C1810")           // Dark brown for cream cards
    static let textMuted = Color(hex: "666666")
    
    // MARK: - Accent Colors
    static let gold = Color(hex: "D4AF37")                 // Royal gold
    static let goldLight = Color(hex: "F4D03F")            // Lighter gold
    static let bronze = Color(hex: "CD7F32")               // Bronze accent
    static let copper = Color(hex: "B87333")               // Copper tones
    
    // MARK: - Fantasy Colors
    static let mystic = Color(hex: "8B5CF6")               // Mystic purple
    static let ember = Color(hex: "F97316")                // Ember orange
    static let forest = Color(hex: "22C55E")               // Forest green
    static let frost = Color(hex: "38BDF8")                // Ice blue
    
    // MARK: - UI Element Colors
    static let buttonPrimary = Color(hex: "D4AF37")        // Gold button
    static let buttonSecondary = Color(hex: "3A3A3A")      // Dark gray button
    static let divider = Color(hex: "2A2A2A")
    static let tabBarBackground = Color(hex: "0D0D0D")
    static let tabBarSelected = Color.white
    static let tabBarUnselected = Color(hex: "666666")
    
    // MARK: - Card Gradients
    static let cardGradient = LinearGradient(
        colors: [Color(hex: "F5E6D3"), Color(hex: "E8D5C4")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Badge Background Gradients
    static let fantasyBackground = LinearGradient(
        colors: [
            Color(hex: "87CEEB").opacity(0.4),  // Sky blue
            Color(hex: "E0E7EE").opacity(0.6),  // Misty
            Color(hex: "B8D4E3").opacity(0.5)   // Light blue
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Timer Pill Style
    static let timerPillBackground = Color(hex: "2A2A2A")
    static let timerPillText = Color.white
    
    // MARK: - Milestone Badge Colors by Type
    static func milestoneColor(for days: Int) -> Color {
        switch days {
        case 0: return ember       // Phoenix Rising
        case 1: return bronze      // First Step
        case 3: return copper      // Early Warrior
        case 7: return gold        // Week Warrior
        case 14: return goldLight  // Fortnight Champion
        case 30: return mystic     // Month Master
        case 60: return forest     // Two Month Hero
        case 90: return frost      // Quarter Century
        default: return gold
        }
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers for Consistent Theming
struct DarkBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.background)
            .preferredColorScheme(.dark)
    }
}

struct CardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func darkBackground() -> some View {
        modifier(DarkBackgroundModifier())
    }
    
    func cardStyle() -> some View {
        modifier(CardStyleModifier())
    }
}

// MARK: - Diamond Icon View (for card decoration)
struct DiamondIcon: View {
    var size: CGFloat = 20
    var color: Color = AppTheme.gold
    
    var body: some View {
        Image(systemName: "suit.diamond.fill")
            .font(.system(size: size))
            .foregroundColor(color)
    }
}

// MARK: - Milestone Badge View
struct MilestoneBadgePill: View {
    let text: String
    var icon: String = "star.fill"
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(AppTheme.textOnCard)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppTheme.cardBackground.opacity(0.9))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.gold.opacity(0.3), lineWidth: 1)
        )
    }
}

