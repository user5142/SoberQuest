import SwiftUI
import Combine

struct Monster: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGSize
    var isSlashed: Bool = false
    var slashAngle: Double = 0.0
    var scale: CGFloat = 0.0
}

struct MonsterSlayingPhaseView: View {
    var onComplete: () -> Void

    @State private var monsters: [Monster] = []
    @State private var dragPath: [CGPoint] = []
    @State private var currentDragPosition: CGPoint? = nil
    @State private var monstersSlashed: Int = 0
    @State private var screenSize: CGSize = .zero

    private let totalMonsters = 7
    private let hitRadius: CGFloat = 40
    private let monsterSpeed: CGFloat = 30.0
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                AppTheme.background
                    .ignoresSafeArea()

                // Instructions
                VStack {
                    Text("Slash the urge monsters!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.top, 60)

                    Text("\(totalMonsters - monstersSlashed) remaining")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.top, 4)

                    Spacer()
                }

                // Monsters
                ForEach(monsters.indices, id: \.self) { index in
                    monsterView(monster: monsters[index], index: index)
                }

                // Drag trail visualization
                Canvas { context, size in
                    guard dragPath.count > 1 else { return }

                    var path = Path()
                    path.move(to: dragPath[0])

                    for point in dragPath.dropFirst() {
                        path.addLine(to: point)
                    }

                    context.stroke(
                        path,
                        with: .color(AppTheme.textPrimary.opacity(0.6)),
                        lineWidth: 4
                    )
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentDragPosition = value.location
                        dragPath.append(value.location)

                        // Keep drag path limited for performance
                        if dragPath.count > 30 {
                            dragPath.removeFirst()
                        }

                        // Check collision with monsters
                        checkMonsterCollisions(at: value.location, dragVelocity: value.translation)
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            dragPath.removeAll()
                            currentDragPosition = nil
                        }
                    }
            )
            .onAppear {
                screenSize = geometry.size
                spawnMonsters(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateMonsterPositions()
            }
        }
    }

    @ViewBuilder
    private func monsterView(monster: Monster, index: Int) -> some View {
        ZStack {
            // Monster image (no bubble)
            Image("urge_monster")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)

            // Slash effect (appears when slashed)
            if monster.isSlashed {
                Rectangle()
                    .fill(AppTheme.textPrimary)
                    .frame(width: 100, height: 3)
                    .rotationEffect(.degrees(monster.slashAngle))
                    .opacity(0.8)
            }
        }
        .position(monster.position)
        .scaleEffect(monster.scale)
        .accessibilityLabel("Urge monster \(index + 1)")
        .accessibilityHint("Swipe across to defeat")
        .onTapGesture {
            // Alternative interaction for VoiceOver users
            if UIAccessibility.isVoiceOverRunning {
                slashMonster(at: index)
            }
        }
    }

    private func spawnMonsters(in size: CGSize) {
        let safeArea: CGFloat = 100 // Padding from edges

        for _ in 0..<totalMonsters {
            let x = CGFloat.random(in: safeArea...(size.width - safeArea))
            let y = CGFloat.random(in: (size.height * 0.2)...(size.height * 0.6))

            // Random velocity for wandering
            let velocityX = CGFloat.random(in: -1...1) * monsterSpeed
            let velocityY = CGFloat.random(in: -1...1) * monsterSpeed

            let monster = Monster(
                position: CGPoint(x: x, y: y),
                velocity: CGSize(width: velocityX, height: velocityY)
            )
            monsters.append(monster)
        }

        // Animate monsters in with stagger
        for index in monsters.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    monsters[index].scale = 1.0
                }
            }
        }
    }

    private func updateMonsterPositions() {
        let safeArea: CGFloat = 50

        for index in monsters.indices {
            // Don't move slashed monsters
            guard !monsters[index].isSlashed else { continue }

            // Update position
            var newX = monsters[index].position.x + monsters[index].velocity.width * 0.05
            var newY = monsters[index].position.y + monsters[index].velocity.height * 0.05

            var newVelocity = monsters[index].velocity

            // Bounce off edges
            if newX < safeArea || newX > screenSize.width - safeArea {
                newVelocity.width = -newVelocity.width
                newX = monsters[index].position.x + newVelocity.width * 0.05
            }

            if newY < screenSize.height * 0.15 || newY > screenSize.height * 0.7 {
                newVelocity.height = -newVelocity.height
                newY = monsters[index].position.y + newVelocity.height * 0.05
            }

            // Randomly change direction occasionally (every ~2-3 seconds on average)
            if Double.random(in: 0...1) < 0.01 {
                newVelocity.width = CGFloat.random(in: -1...1) * monsterSpeed
                newVelocity.height = CGFloat.random(in: -1...1) * monsterSpeed
            }

            monsters[index].position = CGPoint(x: newX, y: newY)
            monsters[index].velocity = newVelocity
        }
    }

    private func checkMonsterCollisions(at point: CGPoint, dragVelocity: CGSize) {
        for index in monsters.indices {
            guard !monsters[index].isSlashed else { continue }

            let distance = hypot(
                point.x - monsters[index].position.x,
                point.y - monsters[index].position.y
            )

            if distance < hitRadius {
                slashMonster(at: index, slashAngle: calculateSlashAngle(velocity: dragVelocity))
            }
        }
    }

    private func slashMonster(at index: Int, slashAngle: Double = 45.0) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            monsters[index].isSlashed = true
            monsters[index].slashAngle = slashAngle
            monsters[index].scale = 0.0
            monstersSlashed += 1
        }

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Check for completion
        if monstersSlashed == totalMonsters {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
        }
    }

    private func calculateSlashAngle(velocity: CGSize) -> Double {
        let angle = atan2(velocity.height, velocity.width) * 180 / .pi
        return angle
    }
}
