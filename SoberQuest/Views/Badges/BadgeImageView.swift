import SwiftUI

struct BadgeImageView: View {
    let imageAssetName: String
    let milestoneDays: Int
    let size: CGFloat
    
    init(imageAssetName: String, milestoneDays: Int, size: CGFloat = 120) {
        self.imageAssetName = imageAssetName
        self.milestoneDays = milestoneDays
        self.size = size
    }
    
    var body: some View {
        Group {
            if let uiImage = UIImage(named: imageAssetName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                // Fallback placeholder with fantasy styling
                placeholderBadge
            }
        }
        .frame(width: size, height: size)
    }
    
    private var placeholderBadge: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            AppTheme.milestoneColor(for: milestoneDays),
                            AppTheme.milestoneColor(for: milestoneDays).opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.04
                )
            
            // Inner gradient fill
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.backgroundSecondary,
                            AppTheme.background
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .padding(size * 0.06)
            
            // Content
            if milestoneDays == 0 {
                // Lantern - fire emoji
                Text("🔥")
                    .font(.system(size: size * 0.4))
            } else {
                // Day number with subtle styling
                VStack(spacing: 2) {
                    Text("\(milestoneDays)")
                        .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.milestoneColor(for: milestoneDays))
                    
                    Text("DAYS")
                        .font(.system(size: size * 0.1, weight: .bold))
                        .tracking(2)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}
