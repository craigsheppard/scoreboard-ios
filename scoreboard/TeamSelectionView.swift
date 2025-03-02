import SwiftUI

struct TeamSelectionView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @ObservedObject var team: TeamConfiguration
    @Binding var isTeamSelectionPresented: Bool
    @State private var showingDeleteAlert = false
    @State private var teamToDelete: SavedTeam?
    @State private var showingUnsavedChangesAlert = false
    @State private var pendingTeam: SavedTeam?
    
    let gameType: GameType
    let isHomeTeam: Bool
    
    // Check if the current team has unsaved changes
    private func hasUnsavedChanges() -> Bool {
        // Look for a saved team with matching name
        let existingTeam = appConfig.getTeams(for: gameType).first { $0.name == team.teamName }
        
        if let existingTeam = existingTeam {
            // Check if properties match
            return existingTeam.primaryColor.toColor() != team.primaryColor ||
                   existingTeam.secondaryColor.toColor() != team.secondaryColor ||
                   existingTeam.fontColor.toColor() != team.fontColor
        }
        
        // If team name doesn't match any saved team and has a non-empty name, consider it unsaved
        return !team.teamName.isEmpty
    }
    
    private func applyTeam(_ savedTeam: SavedTeam) {
        // Check if this is the same team already being used
        if team.teamName == savedTeam.name && 
           team.primaryColor == savedTeam.primaryColor.toColor() &&
           team.secondaryColor == savedTeam.secondaryColor.toColor() &&
           team.fontColor == savedTeam.fontColor.toColor() {
            // Already using this team - just close the sheet
            isTeamSelectionPresented = false
            return
        }
        
        // Check for unsaved changes
        if hasUnsavedChanges() {
            // Store the team we want to apply after confirmation
            pendingTeam = savedTeam
            showingUnsavedChangesAlert = true
        } else {
            // Apply team directly
            team.teamName = savedTeam.name
            team.primaryColor = savedTeam.primaryColor.toColor()
            team.secondaryColor = savedTeam.secondaryColor.toColor()
            team.fontColor = savedTeam.fontColor.toColor()
            team.savedTeamId = savedTeam.id // Store the link to the saved team
            isTeamSelectionPresented = false
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    if hasUnsavedChanges() {
                        // Store a placeholder for new team
                        pendingTeam = nil  // nil indicates "create new team"
                        showingUnsavedChangesAlert = true
                    } else {
                        // Create a blank new team directly
                        team.teamName = "New Team"
                        team.primaryColor = .red
                        team.secondaryColor = .blue
                        team.fontColor = .white
                        isTeamSelectionPresented = false
                    }
                }) {
                    HStack {
                        Text("+ New Team")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // Add horizontal line separator
                Divider()
                
                // Available teams
                let availableTeams = appConfig.getTeams(for: gameType)
                if availableTeams.isEmpty {
                    Text("No saved teams yet")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                } else {
                    ForEach(availableTeams) { savedTeam in
                        Button(action: {
                            applyTeam(savedTeam)
                        }) {
                            HStack {
                                Text(savedTeam.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                // Show color indicators
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(savedTeam.primaryColor.toColor())
                                        .frame(width: 16, height: 16)
                                    
                                    Circle()
                                        .fill(savedTeam.secondaryColor.toColor())
                                        .frame(width: 16, height: 16)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            teamToDelete = availableTeams[index]
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationBarTitle(isHomeTeam ? "Select Home Team" : "Select Away Team", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isTeamSelectionPresented = false
            })
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Team"),
                    message: Text("Are you sure you want to delete '\(teamToDelete?.name ?? "")'?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let team = teamToDelete {
                            appConfig.deleteTeam(team)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Unsaved Changes", isPresented: $showingUnsavedChangesAlert) {
                Button("Save Current Team", role: .none) {
                    // Save current team first
                    appConfig.saveTeam(team: team, for: gameType)
                    
                    // Then apply the new team or create a new one
                    if let savedTeam = pendingTeam {
                        // Apply existing team
                        team.teamName = savedTeam.name
                        team.primaryColor = savedTeam.primaryColor.toColor()
                        team.secondaryColor = savedTeam.secondaryColor.toColor()
                        team.fontColor = savedTeam.fontColor.toColor()
                        team.savedTeamId = savedTeam.id
                    } else {
                        // Create new team
                        team.teamName = "New Team"
                        team.primaryColor = .red
                        team.secondaryColor = .blue
                        team.fontColor = .white
                        team.savedTeamId = nil
                    }
                    isTeamSelectionPresented = false
                }
                
                Button("Discard Changes", role: .destructive) {
                    if let savedTeam = pendingTeam {
                        // Apply existing team
                        team.teamName = savedTeam.name
                        team.primaryColor = savedTeam.primaryColor.toColor()
                        team.secondaryColor = savedTeam.secondaryColor.toColor()
                        team.fontColor = savedTeam.fontColor.toColor()
                        team.savedTeamId = savedTeam.id
                    } else {
                        // Create new team
                        team.teamName = "New Team"
                        team.primaryColor = .red
                        team.secondaryColor = .blue
                        team.fontColor = .white
                        team.savedTeamId = nil
                    }
                    isTeamSelectionPresented = false
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You have unsaved changes to the current team. What would you like to do?")
            }
        }
    }
}