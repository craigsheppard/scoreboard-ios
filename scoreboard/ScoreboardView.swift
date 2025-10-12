import SwiftUI

enum ScoreSide {
    case left
    case right
}

struct ScoreboardView: View {
    @EnvironmentObject var appConfig: AppConfiguration

    var body: some View {
        HStack(spacing: 0) {
            ScoreView(team: appConfig.homeTeam, side: .left) // Home Team
            ScoreView(team: appConfig.awayTeam, side: .right) // Away Team
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
