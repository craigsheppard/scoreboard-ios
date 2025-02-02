import SwiftUI

struct ScoreboardView: View {
    @EnvironmentObject var appConfig: AppConfiguration

    var body: some View {
        HStack(spacing: 0) {
            ScoreView(team: appConfig.homeTeam) // Home Team
            ScoreView(team: appConfig.awayTeam) // Away Team
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
