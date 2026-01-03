import SwiftUI

struct ShareCardView: View {
    let badge: BadgeDefinition
    let addiction: Addiction
    let daysSober: Int
    
    // Sample quotes for different milestones
    private var inspirationalQuote: String {
        switch badge.milestoneDays {
        case 0:
            return "\"All we have to decide is what to do with the time that is given us.\" — Gandalf"
        case 1:
            return "\"All we have to decide is what to do with the time that is given us.\" — Gandalf"
        case 3:
            return "\"It is not the strength of the body, but the strength of the spirit.\" — Tolkien"
        case 7:
            return "\"Even the smallest person can change the course of the future.\" — Galadriel"
        case 14:
            return "\"Courage is not the absence of fear, but acting in spite of it.\" — Unknown"
        case 30:
            return "\"The only way out is through.\" — Robert Frost"
        case 60:
            return "\"Perseverance is not a long race; it is many short races.\" — Walter Elliot"
        case 90:
            return "\"What we achieve inwardly will change outer reality.\" — Plutarch"
        default:
            return "\"All we have to decide is what to do with the time that is given us.\" — Gandalf"
        }
    }
    
    // Stats based on milestone
    private var stats: [(label: String, value: String)] {
        switch badge.milestoneDays {
        case 0...1:
            return [("Clarity", "+1"), ("Discipline", "Low"), ("Hope", "Rising")]
        case 2...7:
            return [("Clarity", "+3"), ("Discipline", "Growing"), ("Hope", "Strong")]
        case 8...30:
            return [("Clarity", "+7"), ("Discipline", "Medium"), ("Hope", "Steady")]
        case 31...60:
            return [("Clarity", "+15"), ("Discipline", "High"), ("Hope", "Unshaken")]
        default:
            return [("Clarity", "+30"), ("Discipline", "Master"), ("Hope", "Radiant")]
        }
    }
    
    var body: some View {
        ZStack {
            // Dark background
            AppTheme.background
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main Card
                cardContent
                    .padding(.horizontal, 24)
                
                // Share button area (for the actual share view)
                shareButton
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .frame(width: 1080, height: 1920)
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: 0) {
            // Card Header with title and diamond
            HStack {
                Text(badge.name)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(AppTheme.textOnCard)

                Spacer()

                // Diamond icon
                Image(systemName: "suit.diamond.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
            
            // Character/Badge with fantasy background
            ZStack {
                // Fantasy background
                fantasyBackgroundView
                    .frame(height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                
                // Character/Badge overlay
                if let uiImage = UIImage(named: badge.imageAssetName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                } else {
                    // Fallback
                    placeholderBadge
                }
            }
            .padding(.top, 24)
            
            // Milestone Badge Pill
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.textOnCard)

                Text(badge.milestoneDays == 0 ? "New Journey" : "Day \(badge.milestoneDays) Milestone")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(AppTheme.textOnCard)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 18)
            .background(Color.white.opacity(0.8))
            .cornerRadius(40)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(AppTheme.divider, lineWidth: 1)
            )
            .padding(.top, 24)
            
            // Quote Section
            VStack(alignment: .leading, spacing: 20) {
                Text(inspirationalQuote)
                    .font(.system(size: 28, weight: .regular))
                    .italic()
                    .foregroundColor(AppTheme.textOnCard.opacity(0.9))
                    .lineSpacing(6)
                
                // Stats
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(stats, id: \.label) { stat in
                        Text("\(stat.label): \(stat.value)")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundColor(AppTheme.textOnCard.opacity(0.8))
                    }
                }
                .padding(.top, 8)
            }
            .padding(32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(AppTheme.cardGradient)
        .cornerRadius(40)
        .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
    }
    
    // MARK: - Fantasy Background
    private var fantasyBackgroundView: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "E8F4F8"),
                    Color(hex: "D4E5ED"),
                    Color(hex: "C5D8E3")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Mystical elements overlay
            GeometryReader { geo in
                // Distant mountains/crystals silhouette
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    
                    path.move(to: CGPoint(x: 0, y: h * 0.7))
                    path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.6))
                    path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.35))
                    path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.55))
                    path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.4))
                    path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.45))
                    path.addLine(to: CGPoint(x: w, y: h * 0.6))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "A8C5D6").opacity(0.6),
                            Color(hex: "8BB3C8").opacity(0.4)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            // Sparkle effects
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: CGFloat.random(in: 4...12), height: CGFloat.random(in: 4...12))
                    .offset(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -200...100)
                    )
                    .blur(radius: 1)
            }
        }
    }
    
    // MARK: - Placeholder Badge
    private var placeholderBadge: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: [
                        AppTheme.milestoneColor(for: badge.milestoneDays).opacity(0.8),
                        AppTheme.milestoneColor(for: badge.milestoneDays)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 300, height: 300)
            .overlay(
                Text(badge.milestoneDays == 0 ? "🔥" : "\(badge.milestoneDays)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
            )
    }
    
    // MARK: - Share Button
    private var shareButton: some View {
        HStack(spacing: 16) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 28, weight: .medium))
            
            Text("Share Your Milestone")
                .font(.system(size: 32, weight: .semibold))
        }
        .foregroundColor(AppTheme.textOnCard)
        .padding(.horizontal, 48)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    func asUIImage() -> UIImage? {
        let targetSize = CGSize(width: 1080, height: 1920)

        // Wrap view with explicit environment values
        let wrappedView = self
            .environment(\.colorScheme, .dark)

        let controller = UIHostingController(rootView: wrappedView)
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = UIColor(AppTheme.background)

        // Force dark mode on the view's trait collection
        controller.overrideUserInterfaceStyle = .dark

        // Attach to a temporary window to ensure proper rendering
        let window = UIWindow(frame: CGRect(origin: .zero, size: targetSize))
        window.rootViewController = controller
        window.isHidden = false
        window.overrideUserInterfaceStyle = .dark

        // Force layout
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        // Render with proper format
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Use 1x scale for consistent 1080x1920 output
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let image = renderer.image { context in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }

        // Clean up
        window.isHidden = true
        window.rootViewController = nil

        return image
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

// MARK: - Share Preview View
struct SharePreviewView: View {
    let badge: BadgeDefinition
    let addiction: Addiction
    @Binding var isPresented: Bool
    var onDismissParent: (() -> Void)? = nil

    @State private var shareImage: UIImage?
    @State private var isGenerating = true

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Preview")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()

                    // Invisible placeholder for centering
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Preview Image
                if isGenerating {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.textSecondary))
                            .scaleEffect(1.2)
                        Text("Generating preview...")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                } else if let image = shareImage {
                    ScrollView {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                            .padding(.horizontal, 24)
                    }
                } else {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Failed to generate image")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                }

                // Action buttons
                VStack(spacing: 12) {
                    // Share button
                    Button(action: {
                        shareImageViaActivityController()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .medium))
                            Text("Share")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.buttonPrimaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(shareImage != nil ? AppTheme.buttonPrimary : AppTheme.textMuted)
                        .cornerRadius(14)
                    }
                    .disabled(shareImage == nil)

                    // Close button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Close")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.backgroundSecondary)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.divider, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            generateShareImage()
        }
    }

    private func generateShareImage() {
        // Generate on background thread to avoid UI freeze
        DispatchQueue.global(qos: .userInitiated).async {
            let shareCard = ShareCardView(
                badge: badge,
                addiction: addiction,
                daysSober: badge.milestoneDays
            )

            // Must create UIImage on main thread due to UIKit requirements
            DispatchQueue.main.async {
                self.shareImage = shareCard.asUIImage()
                self.isGenerating = false
            }
        }
    }

    private func shareImageViaActivityController() {
        guard let image = shareImage else { return }

        // Get the current window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        // Find the topmost presented view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }

        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        // For iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topController.view
            popover.sourceRect = CGRect(
                x: topController.view.bounds.midX,
                y: topController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        topController.present(activityVC, animated: true)
    }
}
