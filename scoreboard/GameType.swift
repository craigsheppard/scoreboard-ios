import SwiftUI

enum GameType: String, CaseIterable, Codable, Identifiable {
    case hockey = "Hockey"
    case basketball = "Basketball"
    case soccer = "Soccer"
    case tableTennis = "Table Tennis"
    
    var id: String { self.rawValue }
}