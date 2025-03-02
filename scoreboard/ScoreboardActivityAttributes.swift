import ActivityKit
import SwiftUI

struct ScoreboardActivityAttributes: ActivityAttributes {
    public typealias ScoreboardStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var homeTeamScore: Int
        var awayTeamScore: Int
    }
    
    var homeTeamName: String
    var awayTeamName: String
    var homeTeamPrimaryColor: CodableColor
    var homeTeamSecondaryColor: CodableColor
    var homeTeamFontColor: CodableColor
    var awayTeamPrimaryColor: CodableColor
    var awayTeamSecondaryColor: CodableColor
    var awayTeamFontColor: CodableColor
}