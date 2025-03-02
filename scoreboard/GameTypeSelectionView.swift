import SwiftUI

struct GameTypeSelectionView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @Binding var selectedGameType: GameType
    @Binding var isGameTypeSelectionPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(GameType.allCases) { gameType in
                    Button(action: {
                        selectedGameType = gameType
                        appConfig.currentGameType = gameType
                        isGameTypeSelectionPresented = false
                    }) {
                        HStack {
                            Text(gameType.rawValue)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedGameType == gameType {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationBarTitle("Select Game Type", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isGameTypeSelectionPresented = false
            })
        }
    }
}