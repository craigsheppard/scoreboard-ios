import SwiftUI
import Combine

// Struct to track the saved state of a team
struct TeamSavedState {
    var name: String
    var primaryColor: String
    var secondaryColor: String
    var fontColor: String
}

class TeamConfiguration: ObservableObject, Codable {
    @Published var teamName: String
    @Published var primaryColor: Color
    @Published var secondaryColor: Color
    @Published var fontColor: Color
    @Published var score: Int
    @Published var savedTeamId: UUID? // Link to the savedTeam this configuration is based on
    
    // Not persisted - used to track changes since last save
    var lastSavedState: TeamSavedState?

    // MARK: - Codable Implementation
    enum CodingKeys: CodingKey {
        case teamName, primaryColor, secondaryColor, fontColor, score, savedTeamId
    }

    init(teamName: String, primaryColor: Color, secondaryColor: Color, fontColor: Color, score: Int = 0, savedTeamId: UUID? = nil) {
        self.teamName = teamName
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.fontColor = fontColor
        self.score = score
        self.savedTeamId = savedTeamId
        
        // Initialize the last saved state to match current properties
        self.lastSavedState = TeamSavedState(
            name: teamName,
            primaryColor: primaryColor.description,
            secondaryColor: secondaryColor.description,
            fontColor: fontColor.description
        )
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.teamName = try container.decode(String.self, forKey: .teamName)
        self.primaryColor = try container.decode(CodableColor.self, forKey: .primaryColor).toColor()
        self.secondaryColor = try container.decode(CodableColor.self, forKey: .secondaryColor).toColor()
        self.fontColor = try container.decode(CodableColor.self, forKey: .fontColor).toColor()
        self.score = try container.decode(Int.self, forKey: .score)
        self.savedTeamId = try container.decodeIfPresent(UUID.self, forKey: .savedTeamId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(teamName, forKey: .teamName)
        try container.encode(CodableColor(color: primaryColor), forKey: .primaryColor)
        try container.encode(CodableColor(color: secondaryColor), forKey: .secondaryColor)
        try container.encode(CodableColor(color: fontColor), forKey: .fontColor)
        try container.encode(score, forKey: .score)
        try container.encodeIfPresent(savedTeamId, forKey: .savedTeamId)
    }
}

