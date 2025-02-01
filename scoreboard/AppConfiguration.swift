import SwiftUI

final class AppConfiguration: ObservableObject {
    @Published var homeTeam: TeamConfiguration
    @Published var awayTeam: TeamConfiguration

    init() {
        // Initial colours match our original scoreboard (red for home, blue for away)
        homeTeam = TeamConfiguration(teamName: "Home", primaryColor: .red, secondaryColor: .blue)
        awayTeam = TeamConfiguration(teamName: "Away", primaryColor: .blue, secondaryColor: .red)
    }
}