import SwiftUI

// A codable wrapper for Color – stores RGBA as Doubles.
struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.alpha = Double(alpha)
    }

    func toColor() -> Color {
        Color(UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha)))
    }
}


// A codable representation for a team.
struct CodableTeam: Codable {
    let teamName: String
    let primaryColor: CodableColor
    let secondaryColor: CodableColor
    let fontColor: CodableColor
    let score: Int
}
