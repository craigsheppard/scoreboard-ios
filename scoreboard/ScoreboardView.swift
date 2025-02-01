import SwiftUI

struct ScoreboardView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    
    var body: some View {
        HStack(spacing: 0) {
            // Home team side (left)
            ZStack {
                appConfig.homeTeam.primaryColor
                OutlinedText(
                    text: "\(appConfig.homeTeam.score)",
                    fontName: "JerseyM54",   // Use your actual internal font name
                    fontSize: 175,
                    textColor: .white,
                    strokeColor: UIColor(appConfig.homeTeam.secondaryColor),
                    strokeWidth: -7.0,
                    textAlignment: .center,
                    kern: 2.0              // Increased kerning between numbers
                )
                .padding(10)             // Extra padding for breathing room
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture { appConfig.homeTeam.score += 1 }
            
            // Away team side (right)
            ZStack {
                appConfig.awayTeam.primaryColor
                OutlinedText(
                    text: "\(appConfig.awayTeam.score)",
                    fontName: "JerseyM54",   // Use your actual internal font name
                    fontSize: 175,
                    textColor: .white,
                    strokeColor: UIColor(appConfig.awayTeam.secondaryColor),
                    strokeWidth: -7.0,
                    textAlignment: .center,
                    kern: 2.0              // Increased kerning between numbers
                )
                .padding(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture { appConfig.awayTeam.score += 1 }
        }
        .ignoresSafeArea()
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView()
            .environmentObject(AppConfiguration())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
