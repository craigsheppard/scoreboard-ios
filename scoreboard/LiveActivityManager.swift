import ActivityKit
import SwiftUI

class LiveActivityManager: ObservableObject {
    @Published var currentActivity: Activity<ScoreboardActivityAttributes>?
    @Published var isLiveActivitySupported: Bool
    
    init() {
        self.isLiveActivitySupported = ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    func startLiveActivity(appConfig: AppConfiguration) {
        guard isLiveActivitySupported else { return }
        
        // Check if we already have an active Live Activity
        if let currentActivity = currentActivity {
            // Update existing activity instead of creating a new one
            updateLiveActivity(appConfig: appConfig)
            return
        }
        
        let homeTeam = appConfig.homeTeam
        let awayTeam = appConfig.awayTeam
        
        let attributes = ScoreboardActivityAttributes(
            homeTeamName: homeTeam.teamName,
            awayTeamName: awayTeam.teamName,
            homeTeamPrimaryColor: CodableColor(color: homeTeam.primaryColor),
            homeTeamSecondaryColor: CodableColor(color: homeTeam.secondaryColor),
            homeTeamFontColor: CodableColor(color: homeTeam.fontColor),
            awayTeamPrimaryColor: CodableColor(color: awayTeam.primaryColor),
            awayTeamSecondaryColor: CodableColor(color: awayTeam.secondaryColor),
            awayTeamFontColor: CodableColor(color: awayTeam.fontColor)
        )
        
        let initialContentState = ScoreboardActivityAttributes.ContentState(
            homeTeamScore: homeTeam.score,
            awayTeamScore: awayTeam.score
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: nil
            )
            currentActivity = activity
            print("Started Live Activity with ID: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateLiveActivity(appConfig: AppConfiguration) {
        guard let activity = currentActivity else { return }
        
        let updatedContentState = ScoreboardActivityAttributes.ContentState(
            homeTeamScore: appConfig.homeTeam.score,
            awayTeamScore: appConfig.awayTeam.score
        )
        
        Task {
            await activity.update(using: updatedContentState)
        }
    }
    
    func updateHomeTeamScore() {
        guard let activity = currentActivity else { return }
        
        // Get current state and increment home team score
        let currentState = activity.content.state
        let updatedContentState = ScoreboardActivityAttributes.ContentState(
            homeTeamScore: currentState.homeTeamScore + 1,
            awayTeamScore: currentState.awayTeamScore
        )
        
        Task {
            await activity.update(using: updatedContentState)
        }
    }
    
    func updateAwayTeamScore() {
        guard let activity = currentActivity else { return }
        
        // Get current state and increment away team score
        let currentState = activity.content.state
        let updatedContentState = ScoreboardActivityAttributes.ContentState(
            homeTeamScore: currentState.homeTeamScore,
            awayTeamScore: currentState.awayTeamScore + 1
        )
        
        Task {
            await activity.update(using: updatedContentState)
        }
    }
    
    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
            DispatchQueue.main.async {
                self.currentActivity = nil
            }
        }
    }
}