import SwiftUI

struct SavedTeam: Identifiable, Codable {
    var id = UUID()
    var name: String
    var primaryColor: CodableColor
    var secondaryColor: CodableColor
    var fontColor: CodableColor
    var gameType: GameType
    
    func toTeamConfiguration() -> TeamConfiguration {
        return TeamConfiguration(
            teamName: name,
            primaryColor: primaryColor.toColor(),
            secondaryColor: secondaryColor.toColor(),
            fontColor: fontColor.toColor(),
            score: 0,
            savedTeamId: id
        )
    }
}