import SwiftUI

/// Basketball scoring state machine
/// - inactive: No basketball gesture in progress
/// - waitingForTarget: Gesture started, targets visible, waiting for hit
/// - targetHit: Target has been hit, completing the gesture
enum BasketballScoringState: Equatable {
    case inactive
    case waitingForTarget
    case targetHit
}

/// Basketball scoring target types
/// - twoPoint: Center target, awards 2 total points
/// - threePoint: Corner target (side-aware), awards 3 total points
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

    // Touch zone configuration
    // Grace area extends 50% of font height around the score number
    private let fontSize: CGFloat = 175
    private var touchZoneGrace: CGFloat { fontSize * 0.5 }
    @State private var hasEnteredTouchZone: Bool = false

    // Basketball-specific state
    @State private var basketballState: BasketballScoringState = .inactive
    @State private var showTargets: Bool = false
    @State private var twoPointHit: Bool = false
    @State private var threePointHit: Bool = false
    @State private var currentGestureLocation: CGPoint = .zero
    @State private var initialPointScored: Bool = false
    @State private var targetPulse: CGFloat = 1.0
    @State private var lastHapticTime: Date = Date()

    // Haptic generator stored as property to prevent deallocation
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                (flashColor ?? team.primaryColor)
                    .animation(.easeOut(duration: 0.07), value: flashColor)

                OutlinedText(
                    text: "\(team.score)",
                    fontName: "JerseyM54",
                    fontSize: fontSize,
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
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Check if finger has entered the touch zone
                        if !hasEnteredTouchZone && isInTouchZone(value.location, in: geometry.size) {
                            hasEnteredTouchZone = true
                        }

                        handleDragChanged(value, in: geometry)
                    }
                    .onEnded { value in
                        // Check if this was a tap (very short movement)
                        let isTap = abs(value.translation.width) < 10 && abs(value.translation.height) < 10

                        if isTap {
                            // In non-basketball modes, allow tap to directly increase the score.
                            // In basketball mode, scoring must go through the 2- and 3-point targets,
                            // so taps should not award points directly.
                            if !isBasketballMode && isInTouchZone(value.startLocation, in: geometry.size) {
                                increaseScore(by: 1)
                            }
                        }

                        handleDragEnded()
                    }
            )
        }
    }

    // MARK: - Basketball Mode Check

    private var isBasketballMode: Bool {
        appConfig.currentGameType == .basketball
    }

    // MARK: - Touch Zone Detection

    /// Calculates the valid touch zone around the score number
    /// The zone is centered on the score text and extends by the grace amount on all sides
    private func calculateTouchZone(in size: CGSize) -> CGRect {
        let centerX = size.width / 2
        let centerY = size.height / 2

        // Estimate score width based on digit count
        // Jersey fonts are typically 55-60% as wide as tall per character
        let digitCount = max(1, String(team.score).count)
        let estimatedDigitWidth = fontSize * 0.58
        let scoreWidth = CGFloat(digitCount) * estimatedDigitWidth

        let halfWidth = scoreWidth / 2 + touchZoneGrace
        let halfHeight = fontSize / 2 + touchZoneGrace

        return CGRect(
            x: centerX - halfWidth,
            y: centerY - halfHeight,
            width: halfWidth * 2,
            height: halfHeight * 2
        )
    }

    /// Checks if a point is within the valid touch zone
    private func isInTouchZone(_ location: CGPoint, in size: CGSize) -> Bool {
        calculateTouchZone(in: size).contains(location)
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

            // Only award points if finger has passed through the touch zone
            if value.translation.height < -swipeThreshold && hasEnteredTouchZone {
                increaseScore(by: 1)
                swipeCompleted = true
                resetDrag()
            } else if value.translation.height > swipeThreshold && hasEnteredTouchZone {
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

            // Award initial +1 point when finger enters the touch zone (only once!)
            // This only happens if we didn't hit a target already
            // Haptic is synced with point award via increaseScore
            if hasEnteredTouchZone && basketballState == .waitingForTarget && !initialPointScored {
                increaseScore(by: 1)
                initialPointScored = true
                // Keep targets visible for continued gesture
            }

            // Handle swipe down (must have entered touch zone)
            if value.translation.height > swipeThreshold && basketballState == .inactive && hasEnteredTouchZone {
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
        lastHapticTime = Date()  // Reset haptic timing for next gesture

        // Reset touch zone tracking
        hasEnteredTouchZone = false
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
            // If initial +1 already scored: add 1 more (total 2)
            // If hitting directly: add all 2 points
            let pointsToAdd = initialPointScored ? 1 : 2
            increaseScore(by: pointsToAdd)

        case .threePoint:
            threePointHit = true
            // If initial +1 already scored: add 2 more (total 3)
            // If hitting directly: add all 3 points
            let pointsToAdd = initialPointScored ? 2 : 3
            increaseScore(by: pointsToAdd)
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

    private func increaseScore(by points: Int) {
        team.score += points
        triggerMultipleHaptics(count: points)
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

    /// Triggers multiple haptic feedbacks with consistent spacing
    /// - Parameter count: Number of haptics to trigger
    /// - Note: Maintains 0.15s spacing between haptics across the entire gesture,
    ///         even when chaining multiple calls (e.g., initial +1 followed by target hit)
    private func triggerMultipleHaptics(count: Int) {
        guard count > 0 else { return }

        let hapticSpacing = 0.15  // Time between each haptic tap
        let timeSinceLastHaptic = Date().timeIntervalSince(lastHapticTime)

        // Calculate initial delay to maintain even spacing from last haptic
        let initialDelay = max(0, hapticSpacing - timeSinceLastHaptic)

        // Schedule each haptic with proper spacing
        for i in 0..<count {
            let delay = initialDelay + Double(i) * hapticSpacing

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [impactGenerator] in
                impactGenerator.impactOccurred(intensity: 1.0)
            }
        }

        // Update lastHapticTime to when the last haptic will fire
        lastHapticTime = Date().addingTimeInterval(initialDelay + Double(count - 1) * hapticSpacing)
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
