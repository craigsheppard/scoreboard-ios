import SwiftUI
import Combine

class TeamConfiguration: ObservableObject, Codable {
    @Published var teamName: String
    @Published var primaryColor: Color
    @Published var secondaryColor: Color
    @Published var fontColor: Color
    @Published var score: Int

    // MARK: - Codable Implementation
    enum CodingKeys: CodingKey {
        case teamName, primaryColor, secondaryColor, fontColor, score
    }

    init(teamName: String, primaryColor: Color, secondaryColor: Color, fontColor: Color, score: Int = 0) {
        self.teamName = teamName
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.fontColor = fontColor
        self.score = score
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.teamName = try container.decode(String.self, forKey: .teamName)
        self.primaryColor = try container.decode(CodableColor.self, forKey: .primaryColor).toColor()
        self.secondaryColor = try container.decode(CodableColor.self, forKey: .secondaryColor).toColor()
        self.fontColor = try container.decode(CodableColor.self, forKey: .fontColor).toColor()
        self.score = try container.decode(Int.self, forKey: .score)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(teamName, forKey: .teamName)
        try container.encode(CodableColor(color: primaryColor), forKey: .primaryColor)
        try container.encode(CodableColor(color: secondaryColor), forKey: .secondaryColor)
        try container.encode(CodableColor(color: fontColor), forKey: .fontColor)
        try container.encode(score, forKey: .score)
    }
}

