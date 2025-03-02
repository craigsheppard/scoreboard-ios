import SwiftUI

struct SavedTeam: Identifiable, Codable {
    var id: UUID
    var name: String
    var primaryColor: CodableColor
    var secondaryColor: CodableColor
    var fontColor: CodableColor
    var gameType: GameType
    
    init(id: UUID = UUID(), name: String, primaryColor: CodableColor, secondaryColor: CodableColor, fontColor: CodableColor, gameType: GameType) {
        self.id = id
        self.name = name
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.fontColor = fontColor
        self.gameType = gameType
    }
    
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