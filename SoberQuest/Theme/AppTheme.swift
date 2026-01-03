import SwiftUI

// MARK: - SoberQuest Dark Minimal Theme
// Clean, minimal dark theme with white accents

struct AppTheme {

    // MARK: - Background Colors
    static let background = Color(hex: "0D0D0D")           // Deep black
    static let backgroundSecondary = Color(hex: "1A1A1A")  // Slightly lighter black
    static let cardBackground = Color(hex: "1A1A1A")       // Dark card (matching secondary)
    static let cardBackgroundDark = Color(hex: "2A2A2A")   // Darker card variant

    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9A9A9A")
    static let textOnCard = Color.white                    // White text on dark cards
    static let textMuted = Color(hex: "666666")

    // MARK: - Accent Colors (now using white/gray tones)
    static let gold = Color.white                          // Primary accent (was gold)
    static let goldLight = Color(hex: "E5E5E5")            // Light accent
    static let bronze = Color(hex: "B0B0B0")               // Neutral gray
    static let copper = Color(hex: "A0A0A0")               // Neutral gray

    // MARK: - Fantasy Colors (kept for badge variety)
    static let mystic = Color(hex: "8B5CF6")               // Mystic purple
    static let ember = Color(hex: "F97316")                // Ember orange
    static let forest = Color(hex: "22C55E")               // Forest green
    static let frost = Color(hex: "38BDF8")                // Ice blue

    // MARK: - UI Element Colors
    static let buttonPrimary = Color.white                 // Light button background
    static let buttonPrimaryText = Color(hex: "1A1A1A")    // Dark text on light button
    static let buttonSecondary = Color(hex: "1A1A1A")      // Darker button variant
    static let divider = Color(hex: "2A2A2A")
    static let tabBarBackground = Color(hex: "0D0D0D")
    static let tabBarSelected = Color.white
    static let tabBarUnselected = Color(hex: "666666")

    // MARK: - Card Styles (flat, no gradient)
    static let cardGradient = LinearGradient(
        colors: [Color(hex: "1A1A1A"), Color(hex: "1A1A1A")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Badge Background (subtle, minimal)
    static let fantasyBackground = LinearGradient(
        colors: [
            Color(hex: "1A1A1A"),
            Color(hex: "1A1A1A")
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
        case 0: return ember       // Lantern
        case 1: return bronze      // First Step
        case 3: return copper      // Early Warrior
        case 7: return textPrimary // Week Warrior
        case 14: return goldLight  // Fortnight Champion
        case 30: return mystic     // Month Master
        case 60: return forest     // Two Month Hero
        case 90: return frost      // Quarter Century
        default: return textPrimary
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
            .background(AppTheme.cardBackgroundDark)
            .cornerRadius(20)
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
        .foregroundColor(AppTheme.textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppTheme.cardBackgroundDark)
        .cornerRadius(20)
    }
}

