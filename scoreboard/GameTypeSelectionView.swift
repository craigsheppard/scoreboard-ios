import SwiftUI

struct GameTypeSelectionView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @Binding var selectedGameType: GameType
    @Binding var isGameTypeSelectionPresented: Bool
    @State private var showingResetScoreAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Game Type")) {
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
                
                Section {
                    Button(action: {
                        showingResetScoreAlert = true
                    }) {
                        Text("Reset Score")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingResetScoreAlert) {
                        Alert(
                            title: Text("Reset Score"),
                            message: Text("Are you sure you want to reset the score?"),
                            primaryButton: .destructive(Text("Reset")) {
                                appConfig.newGame()
                                isGameTypeSelectionPresented = false
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .navigationBarTitle("Game Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                isGameTypeSelectionPresented = false
            })
        }
    }
}