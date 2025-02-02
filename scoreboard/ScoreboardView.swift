import SwiftUI

struct ScoreboardView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @State private var homeDragOffset: CGFloat = 0
    @State private var awayDragOffset: CGFloat = 0
    private let swipeThreshold: CGFloat = 100  // Trigger height for a score change

    var body: some View {
        HStack(spacing: 0) {
            // Home team side (left)
            ZStack {
                appConfig.homeTeam.primaryColor
                
                OutlinedText(
                    text: "\(appConfig.homeTeam.score)",
                    fontName: "JerseyM54",
                    fontSize: 175,
                    textColor: .white,
                    strokeColor: UIColor(appConfig.homeTeam.secondaryColor),
                    strokeWidth: -5.0, // Updated stroke width
                    textAlignment: .center,
                    kern: 2.0
                )
                .padding(10)
                .offset(y: homeDragOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                increaseScore(for: appConfig.homeTeam)
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if abs(value.translation.width) < 40 { // Ensure primarily vertical movement
                            homeDragOffset = value.translation.height * 0.33
                        }
                    }
                    .onEnded { value in
                        if abs(value.translation.width) < 40 { // Ensure it's a vertical swipe
                            if value.translation.height < -swipeThreshold {
                                increaseScore(for: appConfig.homeTeam)
                            } else if value.translation.height > swipeThreshold {
                                decreaseScore(for: appConfig.homeTeam)
                            }
                        }
                        withAnimation(.spring()) {
                            homeDragOffset = 0
                        }
                    }
            )

            // Away team side (right)
            ZStack {
                appConfig.awayTeam.primaryColor
                
                OutlinedText(
                    text: "\(appConfig.awayTeam.score)",
                    fontName: "JerseyM54",
                    fontSize: 175,
                    textColor: .white,
                    strokeColor: UIColor(appConfig.awayTeam.secondaryColor),
                    strokeWidth: -5.0, // Updated stroke width
                    textAlignment: .center,
                    kern: 2.0
                )
                .padding(10)
                .offset(y: awayDragOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                increaseScore(for: appConfig.awayTeam)
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if abs(value.translation.width) < 40 { // Ensure primarily vertical movement
                            awayDragOffset = value.translation.height * 0.33
                        }
                    }
                    .onEnded { value in
                        if abs(value.translation.width) < 40 { // Ensure it's a vertical swipe
                            if value.translation.height < -swipeThreshold {
                                increaseScore(for: appConfig.awayTeam)
                            } else if value.translation.height > swipeThreshold {
                                decreaseScore(for: appConfig.awayTeam)
                            }
                        }
                        withAnimation(.spring()) {
                            awayDragOffset = 0
                        }
                    }
            )
        }
        .ignoresSafeArea()
    }

    // Functions to modify the score with haptic feedback
    private func increaseScore(for team: TeamConfiguration) {
        team.score += 1
        triggerHapticFeedback()
    }

    private func decreaseScore(for team: TeamConfiguration) {
        if team.score > 0 { // Prevent negative scores
            team.score -= 1
            triggerHapticFeedback()
        }
    }

    // Function to trigger haptic feedback
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView()
            .environmentObject(AppConfiguration())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
