import SwiftUI

// Basketball scoring state
enum BasketballScoringState: Equatable {
    case inactive
    case waitingForTarget
    case targetHit
}

// Target type for basketball scoring
enum TargetType {
    case twoPoint
    case threePoint
}

struct ScoreView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @ObservedObject var team: TeamConfiguration
    let side: ScoreSide

    @State private var dragOffset: CGFloat = 0
    @State private var swipeCompleted: Bool = false
    @State private var flashColor: Color? = nil
    private let swipeThreshold: CGFloat = 123

    // Basketball-specific state
    @State private var basketballState: BasketballScoringState = .inactive
    @State private var showTargets: Bool = false
    @State private var twoPointHit: Bool = false
    @State private var threePointHit: Bool = false
    @State private var currentGestureLocation: CGPoint = .zero
    @State private var initialPointScored: Bool = false
    @State private var targetPulse: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                (flashColor ?? team.primaryColor)
                    .animation(.easeOut(duration: 0.07), value: flashColor)

                OutlinedText(
                    text: "\(team.score)",
                    fontName: "JerseyM54",
                    fontSize: 175,
                    textColor: UIColor(team.fontColor),
                    strokeColor: UIColor(team.secondaryColor),
                    strokeWidth: -5.0,
                    textAlignment: .center,
                    kern: 2.0
                )
                .padding(10)
                .offset(y: dragOffset)

                // Basketball targets overlay
                if isBasketballMode && showTargets {
                    basketballTargetsOverlay(in: geometry.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                increaseScore(by: 1)
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        handleDragChanged(value, in: geometry)
                    }
                    .onEnded { _ in
                        handleDragEnded()
                    }
            )
        }
    }

    // MARK: - Basketball Mode Check

    private var isBasketballMode: Bool {
        appConfig.currentGameType == .basketball
    }

    // MARK: - Gesture Handling

    private func handleDragChanged(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        guard !swipeCompleted else { return }

        // Track gesture location
        currentGestureLocation = value.location

        if isBasketballMode {
            handleBasketballDrag(value, in: geometry)
        } else {
            handleStandardDrag(value)
        }
    }

    private func handleStandardDrag(_ value: DragGesture.Value) {
        if abs(value.translation.width) < 70 {
            dragOffset = value.translation.height * 0.33

            if value.translation.height < -swipeThreshold {
                increaseScore(by: 1)
                swipeCompleted = true
                resetDrag()
            } else if value.translation.height > swipeThreshold {
                if team.score > 0 {
                    decreaseScore()
                } else {
                    showInvalidActionFeedback()
                }
                swipeCompleted = true
                resetDrag()
            }
        }
    }

    private func handleBasketballDrag(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        // More lenient horizontal restriction for basketball to allow hitting corner 3-point target
        if abs(value.translation.width) < 200 {
            dragOffset = value.translation.height * 0.33

            // Check if we've crossed the initial threshold (swipe up started)
            if value.translation.height < -30 && !showTargets && basketballState == .inactive {
                showTargets = true
                basketballState = .waitingForTarget
                startTargetPulseAnimation()
            }

            // Check for target hits FIRST (before initial point) - targets take priority
            if basketballState == .waitingForTarget && showTargets {
                checkTargetHits(at: value.location, in: geometry.size)
            }

            // Check if initial threshold crossed for first point (only once!)
            // This only happens if we didn't hit a target already
            if value.translation.height < -swipeThreshold && basketballState == .waitingForTarget && !initialPointScored {
                increaseScore(by: 1, hapticCount: 1)
                initialPointScored = true
                // Keep targets visible for continued gesture
            }

            // Handle swipe down
            if value.translation.height > swipeThreshold && basketballState == .inactive {
                if team.score > 0 {
                    decreaseScore()
                } else {
                    showInvalidActionFeedback()
                }
                swipeCompleted = true
                resetDrag()
            }
        }
    }

    private func handleDragEnded() {
        swipeCompleted = false
        resetDrag()

        // Fade out targets with 200ms animation
        if showTargets {
            withAnimation(.easeOut(duration: 0.2)) {
                showTargets = false
            }
        }

        // Reset basketball state
        basketballState = .inactive
        twoPointHit = false
        threePointHit = false
        initialPointScored = false
        targetPulse = 1.0
    }

    // MARK: - Basketball Target Rendering

    @ViewBuilder
    private func basketballTargetsOverlay(in size: CGSize) -> some View {
        ZStack {
            // 2-Point Target (center top)
            basketballTarget(
                points: 2,
                position: twoPointPosition(in: size),
                color: .white,
                accentColor: .orange,
                isHit: twoPointHit
            )

            // 3-Point Target (corner based on side)
            basketballTarget(
                points: 3,
                position: threePointPosition(in: size),
                color: .white,
                accentColor: .green,
                isHit: threePointHit
            )
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private func basketballTarget(points: Int, position: CGPoint, color: Color, accentColor: Color, isHit: Bool) -> some View {
        ZStack {
            // Outer glow ring
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [accentColor.opacity(0.5), accentColor.opacity(0.0)]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)

            // Main target circle with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color.opacity(0.9), color.opacity(0.6)]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 35
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(accentColor, lineWidth: 4)
                )
                .shadow(color: accentColor.opacity(0.7), radius: isHit ? 25 : 12, x: 0, y: 0)

            // Points text with glow
            Text("\(points)")
                .font(.system(size: 40, weight: .black))
                .foregroundColor(accentColor)
                .shadow(color: accentColor, radius: 8, x: 0, y: 0)
        }
        .scaleEffect(isHit ? 1.5 : targetPulse)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHit)
        .position(position)
    }

    private func startTargetPulseAnimation() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            targetPulse = 1.1
        }
    }

    // MARK: - Target Positioning

    private func twoPointPosition(in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width / 2,
            y: size.height * 0.15  // Same row as 3pt target
        )
    }

    private func threePointPosition(in size: CGSize) -> CGPoint {
        switch side {
        case .left:
            // Top-left corner
            return CGPoint(
                x: size.width * 0.15,
                y: size.height * 0.15
            )
        case .right:
            // Top-right corner
            return CGPoint(
                x: size.width * 0.85,
                y: size.height * 0.15
            )
        }
    }

    // MARK: - Hit Detection

    private func checkTargetHits(at location: CGPoint, in size: CGSize) {
        let hitRadius: CGFloat = 50

        // Check 2-point target
        if !twoPointHit && !threePointHit {
            let twoPointPos = twoPointPosition(in: size)
            let distance2pt = sqrt(pow(location.x - twoPointPos.x, 2) + pow(location.y - twoPointPos.y, 2))

            if distance2pt <= hitRadius {
                handleTargetHit(.twoPoint)
                return
            }

            // Check 3-point target
            let threePointPos = threePointPosition(in: size)
            let distance3pt = sqrt(pow(location.x - threePointPos.x, 2) + pow(location.y - threePointPos.y, 2))

            if distance3pt <= hitRadius {
                handleTargetHit(.threePoint)
                return
            }
        }
    }

    private func handleTargetHit(_ targetType: TargetType) {
        basketballState = .targetHit

        switch targetType {
        case .twoPoint:
            twoPointHit = true
            // If initial point wasn't scored yet, add it too
            let pointsToAdd = initialPointScored ? 1 : 2
            // Haptic count matches points being added RIGHT NOW
            // This ensures total haptics = total points (2 haptics for 2 points)
            increaseScore(by: pointsToAdd, hapticCount: pointsToAdd)
        case .threePoint:
            threePointHit = true
            // If initial point wasn't scored yet, add it too
            let pointsToAdd = initialPointScored ? 2 : 3
            // Haptic count matches points being added RIGHT NOW
            // This ensures total haptics = total points (3 haptics for 3 points)
            increaseScore(by: pointsToAdd, hapticCount: pointsToAdd)
        }

        initialPointScored = true  // Mark as scored even if we skipped the threshold
        swipeCompleted = true
    }

    // MARK: - Drag Reset

    private func resetDrag() {
        withAnimation(.spring()) {
            dragOffset = 0
        }
    }

    // MARK: - Score Management

    private func increaseScore(by points: Int, hapticCount: Int = 1) {
        team.score += points
        triggerMultipleHaptics(count: hapticCount)
        triggerFlash()
    }

    private func decreaseScore() {
        if team.score > 0 {
            team.score -= 1
            triggerHapticFeedback()
            triggerFlash()
        }
    }

    // MARK: - Haptic Feedback

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    private func triggerMultipleHaptics(count: Int) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()

        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                generator.impactOccurred(intensity: 1.0)
            }
        }
    }

    private func showInvalidActionFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Visual Feedback

    private func triggerFlash() {
        flashColor = team.secondaryColor.opacity(0.4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            flashColor = nil
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(
            team: TeamConfiguration(teamName: "Test", primaryColor: .red, secondaryColor: .blue, fontColor: .white),
            side: .left
        )
        .environmentObject(AppConfiguration())
        .previewLayout(.sizeThatFits)
    }
}
