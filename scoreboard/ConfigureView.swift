import SwiftUI
import UIKit

struct ConfigureView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with extra top padding
            Text("Today's Game")
                .font(.largeTitle)
                .padding(.top, 60)
            
            // Two team configuration components stacked vertically
            VStack(spacing: 16) {
                ConfigureTeamComponent(team: appConfig.homeTeam)
                ConfigureTeamComponent(team: appConfig.awayTeam)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Reset Score button
            Button(action: {
                showingResetAlert = true
            }) {
                Text("Reset Score")
                    .font(.headline)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("Reset Score"),
                    message: Text("Are you sure?"),
                    primaryButton: .destructive(Text("Reset")) {
                        // Reset scores for both teams
                        appConfig.homeTeam.score = 0
                        appConfig.awayTeam.score = 0
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
    }
}

struct ConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureView()
            .environmentObject(AppConfiguration())
            .previewInterfaceOrientation(.portrait)
    }
}
