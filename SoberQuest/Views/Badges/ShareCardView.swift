import SwiftUI

struct ShareCardView: View {
    let badge: BadgeDefinition
    let addiction: Addiction
    var useMilestoneDays: Bool = false

    // Quote from badge definition
    private var inspirationalQuote: String {
        badge.shareQuote
    }

    private var timeComponents: (years: Int, months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        addiction.timeComponents
    }

    private var currentDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }

    private var daysLineText: String {
        // When useMilestoneDays is true, show just the badge's milestone day count
        if useMilestoneDays {
            if badge.milestoneDays == 0 {
                return "Day 1"
            } else if badge.milestoneDays == 1 {
                return "1 day"
            } else {
                return "\(badge.milestoneDays) days"
            }
        }

        // Hierarchical display: years > months > days
        if timeComponents.years >= 1 {
            // 1 year or more: show years as primary
            if timeComponents.years == 1 {
                return "1 year"
            } else {
                return "\(timeComponents.years) years"
            }
        } else if timeComponents.months >= 1 {
            // 1 month or more (but less than 1 year): show months as primary
            if timeComponents.months == 1 {
                return "1 month"
            } else {
                return "\(timeComponents.months) months"
            }
        } else {
            // Less than 1 month: show days as primary
            let totalDays = timeComponents.days
            if totalDays == 1 {
                return "1 day"
            } else if totalDays == 0 {
                return "Day 1"
            } else {
                return "\(totalDays) days"
            }
        }
    }

    private var timeLineText: String {
        // Secondary display based on primary tier
        if timeComponents.years >= 1 {
            // Primary is years, show months/days/hours in secondary
            var parts: [String] = []
            if timeComponents.months > 0 {
                parts.append("\(timeComponents.months)mo")
            }
            if timeComponents.days > 0 {
                parts.append("\(timeComponents.days)d")
            }
            parts.append(String(format: "%dhr %02dm", timeComponents.hours, timeComponents.minutes))
            return parts.joined(separator: " ")
        } else if timeComponents.months >= 1 {
            // Primary is months, show days/hours/minutes in secondary
            var parts: [String] = []
            if timeComponents.days > 0 {
                parts.append("\(timeComponents.days)d")
            }
            parts.append(String(format: "%dhr %02dm", timeComponents.hours, timeComponents.minutes))
            return parts.joined(separator: " ")
        } else {
            // Primary is days, show hours/minutes/seconds in secondary
            return "\(timeComponents.hours)hr \(timeComponents.minutes)min \(timeComponents.seconds)s"
        }
    }

    var body: some View {
        ZStack {
            // Solid background
            Color(hex: "191918")

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Badge - central focus, large
                if let uiImage = UIImage(named: badge.imageAssetName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 900, maxHeight: 900)
                        .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
                } else {
                    placeholderBadge
                }

                Spacer()
                    .frame(height: 80)

                if useMilestoneDays {
                    // Badge name and milestone day for collection shares
                    Text(badge.name)
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()
                        .frame(height: 20)

                    Text(badge.milestoneDays == 0 ? "The Start" : "Day \(badge.milestoneDays)")
                        .font(.system(size: 160, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                } else {
                    // Badge name above addiction-free label for main screen shares
                    Text(badge.name)
                        .font(.system(size: 68, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Spacer()
                        .frame(height: 40)

                    // Addiction-free label for main screen shares
                    Text("You've been \(addiction.name.lowercased())-free for:")
                        .font(.system(size: 42, weight: .medium))
                        .tracking(2.5)
                        .foregroundColor(AppTheme.textSecondary)

                    Spacer()
                        .frame(height: 20)

                    // Days sober - emphasized achievement
                    Text(daysLineText)
                        .font(.system(size: 160, weight: .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                }

                // Only show time display when not using milestone days
                if !useMilestoneDays {
                    Spacer()
                        .frame(height: 12)

                    // Time display (hours:minutes:seconds)
                    Text(timeLineText)
                        .font(.system(size: 72, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
                    .frame(height: useMilestoneDays ? 80 : 60)

                // Quote with border
                Text(inspirationalQuote)
                    .font(.system(size: 32, weight: .regular))
                    .italic()
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 32)
                    .frame(maxWidth: 600)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(AppTheme.divider, lineWidth: 2)
                    )

                Spacer()

                // Bottom branding with date (date only for home view shares)
                HStack {
                    if !useMilestoneDays {
                        Text(currentDateFormatted)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    Text("SoberQuest")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 60)
            }
            .padding(40)
        }
        .frame(width: 1200, height: 2000)
    }

    // MARK: - Placeholder Badge
    private var placeholderBadge: some View {
        RoundedRectangle(cornerRadius: 48)
            .fill(AppTheme.cardBackgroundDark)
            .frame(width: 600, height: 600)
            .overlay(
                Text(badge.milestoneDays == 0 ? "🔥" : "\(badge.milestoneDays)")
                    .font(.system(size: 200, weight: .bold))
                    .foregroundColor(.white)
            )
    }

    func asUIImage() -> UIImage? {
        let targetSize = CGSize(width: 1200, height: 2000)

        // Wrap view with explicit environment values
        let wrappedView = self
            .environment(\.colorScheme, .dark)

        let controller = UIHostingController(rootView: wrappedView)
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = UIColor(Color(hex: "191918"))

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
        format.scale = 1.0 // Use 1x scale for consistent 1600x2000 output
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
    var useMilestoneDays: Bool = false

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
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 24)
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

                Spacer()

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
                useMilestoneDays: useMilestoneDays
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
