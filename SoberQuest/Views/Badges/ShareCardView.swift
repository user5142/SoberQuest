import SwiftUI

struct ShareCardView: View {
    let badge: BadgeDefinition
    let addiction: Addiction
    let daysSober: Int
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 20) {
                // Badge artwork
                if let uiImage = UIImage(named: badge.imageAssetName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                } else {
                    // Fallback placeholder
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Text("\(badge.milestoneDays)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                
                // Main text
                Text("\(daysSober) Days Sober")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                // Addiction label
                Text("from \(addiction.name)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                // App branding
                Text("SoberQuest")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 20)
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1920) // Instagram Story size
    }
    
    func asUIImage() -> UIImage? {
        let targetSize = CGSize(width: 1080, height: 1920)
        let controller = UIHostingController(rootView: self)
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

