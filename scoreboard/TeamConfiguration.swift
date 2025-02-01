import SwiftUI

final class TeamConfiguration: ObservableObject, Identifiable {
    @Published var teamName: String
    @Published var primaryColor: Color
    @Published var secondaryColor: Color
    @Published var score: Int

    init(teamName: String, primaryColor: Color, secondaryColor: Color, score: Int = 0) {
        self.teamName = teamName
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.score = score
    }
}
