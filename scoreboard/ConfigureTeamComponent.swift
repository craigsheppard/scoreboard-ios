import SwiftUI

struct ConfigureTeamComponent: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @ObservedObject var team: TeamConfiguration
    @State private var isTeamSelectionPresented = false
    @State private var showingSaveTeamAlert = false
    
    var isHomeTeam: Bool
    
    // Check if the current team has unsaved changes
    private var hasUnsavedChanges: Bool {
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
            if let existingTeam = appConfig.getTeams(for: appConfig.currentGameType)
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
    
    // Check if this is an existing team being edited (vs a brand new team)
    private var isExistingTeam: Bool {
        // If we have a saved team ID, this is definitely an existing team
        if let savedTeamId = team.savedTeamId {
            return appConfig.getTeams(for: appConfig.currentGameType)
                .contains { $0.id == savedTeamId }
        }
        // Otherwise check if there's a team with the same name
        return appConfig.getTeams(for: appConfig.currentGameType)
            .contains { $0.name == team.teamName }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                TextField("Team Name", text: $team.teamName)
                    .font(.title2)
                    .padding(8)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: team.teamName) {}
                
                Button(action: {
                    isTeamSelectionPresented = true
                }) {
                    Image(systemName: "rectangle.stack.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }

            HStack {
                VStack {
                    Text("Primary Color")
                    ColorPicker("", selection: $team.primaryColor)
                        .labelsHidden()
                        .onChange(of: team.primaryColor) {}
                }
                VStack {
                    Text("Secondary Color")
                    ColorPicker("", selection: $team.secondaryColor)
                        .labelsHidden()
                        .onChange(of: team.secondaryColor) {}
                }
                VStack {
                    Text("Font Color")
                    ColorPicker("", selection: $team.fontColor)
                        .labelsHidden()
                        .onChange(of: team.fontColor) {}
                }
            }
            
            if hasUnsavedChanges {
                Button(action: {
                    showingSaveTeamAlert = true
                }) {
                    HStack {
                        Spacer()
                        Text(isExistingTeam ? "Save Changes" : "Save Team")
                            .font(.footnote)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        Spacer()
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .alert(isPresented: $showingSaveTeamAlert) {
                    Alert(
                        title: Text(isExistingTeam ? "Save Changes" : "Save Team"),
                        message: Text(isExistingTeam ?
                                     "Save changes to '\(team.teamName)'?" :
                                     "Save '\(team.teamName)' as a \(appConfig.currentGameType.rawValue) team?"),
                        primaryButton: .default(Text("Save")) {
                            appConfig.saveTeam(team: team, for: appConfig.currentGameType)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary, lineWidth: 1))
        .padding()
        .sheet(isPresented: $isTeamSelectionPresented) {
            TeamSelectionView(
                team: team,
                isTeamSelectionPresented: $isTeamSelectionPresented,
                gameType: appConfig.currentGameType,
                isHomeTeam: isHomeTeam
            )
            .environmentObject(appConfig)
        }
    }
}

struct ConfigureTeamComponent_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureTeamComponent(
            team: TeamConfiguration(teamName: "Test", primaryColor: .red, secondaryColor: .blue, fontColor: .white),
            isHomeTeam: true
        )
        .environmentObject(AppConfiguration())
        .previewLayout(.sizeThatFits)
    }
}
