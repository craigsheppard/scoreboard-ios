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
    
    // Check if the current team has unsaved changes - using same logic as in ConfigureTeamComponent
    private func hasUnsavedChanges() -> Bool {
        // Use the exact same logic that's used in ConfigureTeamComponent for consistency
        
        // If we have a lastSavedState record, compare current values to it
        if let lastSaved = team.lastSavedState {
            // Check if any property has changed since the last save
            let nameChanged = lastSaved.name != team.teamName
            let primaryColorChanged = lastSaved.primaryColor != team.primaryColor.description
            let secondaryColorChanged = lastSaved.secondaryColor != team.secondaryColor.description
            let fontColorChanged = lastSaved.fontColor != team.fontColor.description
            
            return nameChanged || primaryColorChanged || secondaryColorChanged || fontColorChanged
        }
        
        // If we have a savedTeamId but no lastSavedState (shouldn't happen normally)
        if let savedTeamId = team.savedTeamId {
            // Find the saved team with this ID
            if let existingTeam = appConfig.getTeams(for: gameType)
                .first(where: { $0.id == savedTeamId }) {
                
                // Compare against the saved team in the database
                let nameChanged = existingTeam.name != team.teamName
                let primaryColorChanged = existingTeam.primaryColor.toColor().description != team.primaryColor.description
                let secondaryColorChanged = existingTeam.secondaryColor.toColor().description != team.secondaryColor.description
                let fontColorChanged = existingTeam.fontColor.toColor().description != team.fontColor.description
                
                return nameChanged || primaryColorChanged || secondaryColorChanged || fontColorChanged
            }
            
            // If we have a saved ID but can't find the team, something is wrong
            return true
        }
        
        // No saved team ID means this is a new unsaved team, but only if it has a name
        return !team.teamName.isEmpty && team.teamName != "New Team"
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
            
            // Always update the lastSavedState to the current state when applying a team
            team.lastSavedState = TeamSavedState(
                name: savedTeam.name,
                primaryColor: team.primaryColor.description,
                secondaryColor: team.secondaryColor.description,
                fontColor: team.fontColor.description
            )
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
                        // Create a blank new team directly - always clear the ID
                        team.teamName = "New Team"
                        team.primaryColor = .red
                        team.secondaryColor = .blue
                        team.fontColor = .white
                        team.savedTeamId = nil  // Crucial - ensure this is a NEW team
                        
                        // Update the lastSavedState to match the new team's initial state
                        team.lastSavedState = TeamSavedState(
                            name: "New Team",
                            primaryColor: team.primaryColor.description,
                            secondaryColor: team.secondaryColor.description,
                            fontColor: team.fontColor.description
                        )
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
                        
                        // Always update the lastSavedState when applying a team
                        team.lastSavedState = TeamSavedState(
                            name: savedTeam.name,
                            primaryColor: team.primaryColor.description,
                            secondaryColor: team.secondaryColor.description,
                            fontColor: team.fontColor.description
                        )
                    } else {
                        // Create new team
                        team.teamName = "New Team"
                        team.primaryColor = .red
                        team.secondaryColor = .blue
                        team.fontColor = .white
                        team.savedTeamId = nil
                        
                        // Update the lastSavedState to match the new team's initial state
                        team.lastSavedState = TeamSavedState(
                            name: "New Team",
                            primaryColor: team.primaryColor.description,
                            secondaryColor: team.secondaryColor.description, 
                            fontColor: team.fontColor.description
                        )
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
                        
                        // Always update the lastSavedState when applying a team
                        team.lastSavedState = TeamSavedState(
                            name: savedTeam.name,
                            primaryColor: team.primaryColor.description,
                            secondaryColor: team.secondaryColor.description,
                            fontColor: team.fontColor.description
                        )
                    } else {
                        // Create new team
                        team.teamName = "New Team"
                        team.primaryColor = .red
                        team.secondaryColor = .blue
                        team.fontColor = .white
                        team.savedTeamId = nil
                        
                        // Update the lastSavedState to match the new team's initial state
                        team.lastSavedState = TeamSavedState(
                            name: "New Team",
                            primaryColor: team.primaryColor.description,
                            secondaryColor: team.secondaryColor.description,
                            fontColor: team.fontColor.description
                        )
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