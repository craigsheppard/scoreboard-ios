import SwiftUI
import UIKit

struct ConfigureView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @State private var showingNewGameAlert = false
    @State private var isGameTypeSelectionPresented = false
    @State private var selectedGameType: GameType = .hockey
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with game type selection
            VStack {
                Text("Today's Game")
                    .font(.largeTitle)
                    .padding(.top, 40)
                
                Button(action: {
                    selectedGameType = appConfig.currentGameType
                    isGameTypeSelectionPresented = true
                }) {
                    HStack {
                        Text(appConfig.currentGameType.rawValue)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            // Two team configuration components stacked vertically
            VStack(spacing: 16) {
                ConfigureTeamComponent(team: appConfig.homeTeam, isHomeTeam: true)
                ConfigureTeamComponent(team: appConfig.awayTeam, isHomeTeam: false)
            }
            .padding(.top, 10)
            
            Spacer()
            
            // New Game button (replacing Reset Score)
            Button(action: {
                showingNewGameAlert = true
            }) {
                Text("New Game")
                    .font(.headline)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .alert(isPresented: $showingNewGameAlert) {
                Alert(
                    title: Text("New Game"),
                    message: Text("Start a new game? This will reset the score."),
                    primaryButton: .default(Text("New Game")) {
                        // Reset scores for both teams
                        appConfig.newGame()
                    },
                    secondaryButton: .cancel()
                )
            }
            
            // "Go" button to force landscape
            Button(action: {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeLeft)
                    windowScene.requestGeometryUpdate(geometryPreferences) { error in
                        print("Error updating geometry: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Go")
                    .font(.largeTitle)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $isGameTypeSelectionPresented) {
            GameTypeSelectionView(
                selectedGameType: $selectedGameType,
                isGameTypeSelectionPresented: $isGameTypeSelectionPresented
            )
            .environmentObject(appConfig)
        }
    }
}

struct ConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureView()
            .environmentObject(AppConfiguration())
            .previewInterfaceOrientation(.portrait)
    }
}
