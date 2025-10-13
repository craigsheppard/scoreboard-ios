import SwiftUI

struct TeamSelectionViewRedesigned: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @ObservedObject var team: TeamConfiguration
    @Binding var isTeamSelectionPresented: Bool
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var teamToDelete: SavedTeam?
    @State private var showingUnsavedChangesAlert = false
    @State private var pendingTeam: SavedTeam?

    let gameType: GameType
    let isHomeTeam: Bool

    // MARK: - Computed Properties

    private var filteredTeams: [SavedTeam] {
        let teams = appConfig.getTeams(for: gameType)
        if searchText.isEmpty {
            return teams
        }
        return teams.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }

    private var hasUnsavedChanges: Bool {
        if let lastSaved = team.lastSavedState {
            return lastSaved.name != team.teamName ||
                   lastSaved.primaryColor != team.primaryColor.description ||
                   lastSaved.secondaryColor != team.secondaryColor.description ||
                   lastSaved.fontColor != team.fontColor.description
        }

        if let savedTeamId = team.savedTeamId,
           let existingTeam = appConfig.getTeams(for: gameType).first(where: { $0.id == savedTeamId }) {
            return existingTeam.name != team.teamName ||
                   existingTeam.primaryColor.toColor().description != team.primaryColor.description ||
                   existingTeam.secondaryColor.toColor().description != team.secondaryColor.description ||
                   existingTeam.fontColor.toColor().description != team.fontColor.description
        }

        return !team.teamName.isEmpty && team.teamName != "New Team"
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                if !appConfig.getTeams(for: gameType).isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search teams...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                }

                // Teams grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        // New team card
                        newTeamCard

                        // Existing teams
                        ForEach(filteredTeams) { savedTeam in
                            teamCard(for: savedTeam)
                        }
                    }
                    .padding()
                }

                // Empty state
                if filteredTeams.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No teams found")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text("Try a different search term")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            }
            .navigationBarTitle(isHomeTeam ? "Select Home Team" : "Select Away Team", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    appConfig.toggleTeamSelectionStyle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                        Text("Classic")
                    }
                    .font(.caption)
                },
                trailing: Button("Done") {
                    isTeamSelectionPresented = false
                }
            )
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
                    appConfig.saveTeam(team: team, for: gameType)
                    applyPendingAction()
                }

                Button("Discard Changes", role: .destructive) {
                    applyPendingAction()
                }

                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You have unsaved changes to the current team. What would you like to do?")
            }
        }
    }

    // MARK: - View Components

    private var newTeamCard: some View {
        Button(action: {
            handleNewTeamSelection()
        }) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))

                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }
                .frame(height: 120)

                Text("New Team")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func teamCard(for savedTeam: SavedTeam) -> some View {
        Button(action: {
            applyTeam(savedTeam)
        }) {
            VStack(spacing: 0) {
                // Team colors preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    savedTeam.primaryColor.toColor(),
                                    savedTeam.secondaryColor.toColor()
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Team name overlay
                    Text(savedTeam.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(savedTeam.fontColor.toColor())
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .padding()
                }
                .frame(height: 120)

                // Action buttons
                HStack(spacing: 0) {
                    // Select button is the entire tap area above

                    Spacer()

                    Button(action: {
                        teamToDelete = savedTeam
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(12)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(height: 40)
                .background(Color(.systemGray6))
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helper Methods

    private func handleNewTeamSelection() {
        if hasUnsavedChanges {
            pendingTeam = nil
            showingUnsavedChangesAlert = true
        } else {
            createNewTeam()
            isTeamSelectionPresented = false
        }
    }

    private func applyTeam(_ savedTeam: SavedTeam) {
        // Check if already using this team
        if team.teamName == savedTeam.name &&
           team.primaryColor == savedTeam.primaryColor.toColor() &&
           team.secondaryColor == savedTeam.secondaryColor.toColor() &&
           team.fontColor == savedTeam.fontColor.toColor() {
            isTeamSelectionPresented = false
            return
        }

        if hasUnsavedChanges {
            pendingTeam = savedTeam
            showingUnsavedChangesAlert = true
        } else {
            applyTeamDirectly(savedTeam)
            isTeamSelectionPresented = false
        }
    }

    private func applyPendingAction() {
        if let savedTeam = pendingTeam {
            applyTeamDirectly(savedTeam)
        } else {
            createNewTeam()
        }
        isTeamSelectionPresented = false
    }

    private func applyTeamDirectly(_ savedTeam: SavedTeam) {
        team.teamName = savedTeam.name
        team.primaryColor = savedTeam.primaryColor.toColor()
        team.secondaryColor = savedTeam.secondaryColor.toColor()
        team.fontColor = savedTeam.fontColor.toColor()
        team.savedTeamId = savedTeam.id

        team.lastSavedState = TeamSavedState(
            name: savedTeam.name,
            primaryColor: team.primaryColor.description,
            secondaryColor: team.secondaryColor.description,
            fontColor: team.fontColor.description
        )
    }

    private func createNewTeam() {
        team.teamName = "New Team"
        team.primaryColor = .red
        team.secondaryColor = .blue
        team.fontColor = .white
        team.savedTeamId = nil

        team.lastSavedState = TeamSavedState(
            name: "New Team",
            primaryColor: team.primaryColor.description,
            secondaryColor: team.secondaryColor.description,
            fontColor: team.fontColor.description
        )
    }
}

struct TeamSelectionViewRedesigned_Previews: PreviewProvider {
    static var previews: some View {
        TeamSelectionViewRedesigned(
            team: TeamConfiguration(teamName: "Test", primaryColor: .red, secondaryColor: .blue, fontColor: .white),
            isTeamSelectionPresented: .constant(true),
            gameType: .hockey,
            isHomeTeam: true
        )
        .environmentObject(AppConfiguration())
    }
}
