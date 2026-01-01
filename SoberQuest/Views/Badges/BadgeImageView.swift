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
                // Fallback placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Text("\(milestoneDays)")
                            .font(.system(size: size * 0.4, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

