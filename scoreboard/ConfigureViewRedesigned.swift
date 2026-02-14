import SwiftUI
import UIKit

struct ConfigureViewRedesigned: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @State private var showingNewGameAlert = false
    @State private var isGameTypeSelectionPresented = false
    @State private var selectedGameType: GameType = .hockey

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header section
                headerSection

                // Teams section
                teamsSection

                Spacer()

                // Action buttons
                actionButtons
            }
            .padding()
        }
        .sheet(isPresented: $isGameTypeSelectionPresented) {
            GameTypeSelectionView(
                selectedGameType: $selectedGameType,
                isGameTypeSelectionPresented: $isGameTypeSelectionPresented
            )
            .environmentObject(appConfig)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Today's Game")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)

            // Game type selector
            Button(action: {
                selectedGameType = appConfig.currentGameType
                isGameTypeSelectionPresented = true
            }) {
                HStack(spacing: 8) {
                    gameTypeIcon

                    Text(appConfig.currentGameType.rawValue.capitalized)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title3)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.top, 20)
    }

    private var gameTypeIcon: some View {
        Group {
            switch appConfig.currentGameType {
            case .hockey:
                Image(systemName: "sportscourt")
            case .basketball:
                Image(systemName: "basketball")
            case .soccer:
                Image(systemName: "soccerball")
            case .tableTennis:
                Image(systemName: "table.furniture")
            }
        }
        .font(.title3)
    }

    // MARK: - Teams Section

    private var teamsSection: some View {
        VStack(spacing: 16) {
            // Home team card
            teamCard(team: appConfig.homeTeam, label: "Home", isHome: true)

            // Swap button
            swapButton

            // Away team card
            teamCard(team: appConfig.awayTeam, label: "Away", isHome: false)
        }
        .padding(.horizontal, 4)
    }

    private func teamCard(team: TeamConfiguration, label: String, isHome: Bool) -> some View {
        VStack(spacing: 0) {
            // Team label
            HStack {
                Text(label.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray5))
                    .cornerRadius(8, corners: [.topLeft, .topRight])

                Spacer()
            }

            // Team preview
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        team.primaryColor,
                        team.secondaryColor
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Team name
                Text(team.teamName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(team.fontColor)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .padding()
            }
            .frame(height: 100)

            // Configuration component
            ConfigureTeamComponent(team: team, isHomeTeam: isHome)
                .padding(0)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    private var swapButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appConfig.swapTeams()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title3)
                Text("Swap Sides")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(20)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // New Game button
            Button(action: {
                showingNewGameAlert = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("New Game")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .alert(isPresented: $showingNewGameAlert) {
                Alert(
                    title: Text("New Game"),
                    message: Text("Start a new game? This will reset the score."),
                    primaryButton: .default(Text("New Game")) {
                        appConfig.newGame()
                    },
                    secondaryButton: .cancel()
                )
            }

            // Go button
            Button(action: {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeLeft)
                    windowScene.requestGeometryUpdate(geometryPreferences) { error in
                        print("Error updating geometry: \(error.localizedDescription)")
                    }
                }
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("Start Game")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 6)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 10)
    }
}

// Helper extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ConfigureViewRedesigned_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureViewRedesigned()
            .environmentObject(AppConfiguration())
            .previewInterfaceOrientation(.portrait)
    }
}
