import SwiftUI

struct BadgeUnlockView: View {
    let badge: BadgeDefinition
    let addiction: Addiction
    @Binding var isPresented: Bool
    let onShare: (UIImage) -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Badge with animation
                BadgeImageView(imageAssetName: badge.imageAssetName, milestoneDays: badge.milestoneDays, size: 200)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            scale = 1.0
                            opacity = 1.0
                        }
                    }
                
                VStack(spacing: 8) {
                    Text(badge.milestoneDays == 0 ? "Beginning My Journey" : "\(badge.milestoneDays) Days Sober")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(badge.name)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        let shareCard = ShareCardView(badge: badge, addiction: addiction, daysSober: badge.milestoneDays)
                        if let image = shareCard.asUIImage() {
                            onShare(image)
                        }
                    }) {
                        Text("Share Badge")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

