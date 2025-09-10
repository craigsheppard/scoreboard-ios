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
                ConfigureTeamComponent(team: appConfig.homeTeam, isHomeTeam: appConfig.isHomeTeamA)
                ConfigureTeamComponent(team: appConfig.awayTeam, isHomeTeam: !appConfig.isHomeTeamA)
            }
            .padding(.top, 10)
            
            Spacer()
            
            // "Go" button to force landscape
            Button(action: {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeLeft)
                    windowScene.requestGeometryUpdate(geometryPreferences) { error in
                        print("Error updating geometry: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Scoreboard")
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
