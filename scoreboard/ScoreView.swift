import SwiftUI

struct ScoreView: View {
    @ObservedObject var team: TeamConfiguration
    @State private var dragOffset: CGFloat = 0
    @State private var swipeCompleted: Bool = false
    @State private var flashColor: Color? = nil
    @EnvironmentObject var liveActivityManager: LiveActivityManager
    @EnvironmentObject var appConfig: AppConfiguration
    private let swipeThreshold: CGFloat = 123
    
    // Determine if this is the home or away team view
    private var isHomeTeam: Bool {
        return team.teamName == appConfig.homeTeam.teamName
    }

    var body: some View {
        ZStack {
            (flashColor ?? team.primaryColor)
                .animation(.easeOut(duration: 0.07), value: flashColor)

            OutlinedText(
                text: "\(team.score)",
                fontName: "JerseyM54",
                fontSize: 175,
                textColor: UIColor(team.fontColor),  // Now uses user-selected font color
                strokeColor: UIColor(team.secondaryColor),
                strokeWidth: -5.0,
                textAlignment: .center,
                kern: 2.0
            )
            .padding(10)
            .offset(y: dragOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            increaseScore()
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    guard !swipeCompleted else { return }

                    if abs(value.translation.width) < 70 {
                        dragOffset = value.translation.height * 0.33

                        if value.translation.height < -swipeThreshold {
                            increaseScore()
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
                .onEnded { _ in
                    swipeCompleted = false
                    resetDrag()
                }
        )
    }

    private func resetDrag() {
        withAnimation(.spring()) {
            dragOffset = 0
        }
    }

    private func increaseScore() {
        team.score += 1
        triggerHapticFeedback()
        triggerFlash()
        
        // Update Live Activity after score change
        if liveActivityManager.currentActivity != nil {
            liveActivityManager.updateLiveActivity(appConfig: appConfig)
        }
    }

    private func decreaseScore() {
        if team.score > 0 {
            team.score -= 1
            triggerHapticFeedback()
            triggerFlash()
            
            // Update Live Activity after score change
            if liveActivityManager.currentActivity != nil {
                liveActivityManager.updateLiveActivity(appConfig: appConfig)
            }
        }
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    private func showInvalidActionFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private func triggerFlash() {
        flashColor = team.secondaryColor.opacity(0.4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            flashColor = nil
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(team: TeamConfiguration(teamName: "Test", primaryColor: .red, secondaryColor: .blue, fontColor: .white))
            .environmentObject(LiveActivityManager())
            .environmentObject(AppConfiguration())
            .previewLayout(.sizeThatFits)
    }
}
