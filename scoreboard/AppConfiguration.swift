import SwiftUI
import Combine

final class AppConfiguration: ObservableObject {
    @Published var homeTeam: TeamConfiguration
    @Published var awayTeam: TeamConfiguration
    @Published var currentGameType: GameType = .hockey
    @Published var savedTeams: [SavedTeam] = []
    @Published var iCloudAvailable: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let storageKey = "AppConfigurationKey"
    private let savedTeamsKey = "SavedTeamsKey"

    struct SavedConfiguration: Codable {
        let home: CodableTeam
        let away: CodableTeam
        let gameType: GameType
    }

    init() {
        // Default setup
        self.homeTeam = TeamConfiguration(teamName: "Home", primaryColor: .red, secondaryColor: .blue, fontColor: .white)
        self.awayTeam = TeamConfiguration(teamName: "Away", primaryColor: .blue, secondaryColor: .red, fontColor: .white)
        
        // First load saved teams from UserDefaults before team configs
        loadTeamsFromLocal()
        
        // Load current game configuration from UserDefaults
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedConfig = try? JSONDecoder().decode(SavedConfiguration.self, from: data) {
            self.homeTeam = TeamConfiguration(
                teamName: savedConfig.home.teamName,
                primaryColor: savedConfig.home.primaryColor.toColor(),
                secondaryColor: savedConfig.home.secondaryColor.toColor(),
                fontColor: savedConfig.home.fontColor.toColor(),
                score: savedConfig.home.score
            )
            self.awayTeam = TeamConfiguration(
                teamName: savedConfig.away.teamName,
                primaryColor: savedConfig.away.primaryColor.toColor(),
                secondaryColor: savedConfig.away.secondaryColor.toColor(),
                fontColor: savedConfig.away.fontColor.toColor(),
                score: savedConfig.away.score
            )
            self.currentGameType = savedConfig.gameType
        }
        
        // Check iCloud availability
        CloudKitManager.shared.checkCloudKitAvailability { [weak self] available in
            DispatchQueue.main.async {
                self?.iCloudAvailable = available
                
                if available {
                    // Load teams from iCloud and merge with local teams
                    self?.loadTeamsFromCloud(mergeWithLocal: true)
                    
                    // Subscribe to CloudKit changes
                    self?.subscribeToCloudKitChanges()
                }
            }
        }

        setupAutoSave()
    }
    
    private func subscribeToCloudKitChanges() {
        // Subscribe to the CloudKit notification publisher
        CloudKitManager.shared.teamsDidChangePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Reload teams from CloudKit when notified of changes
                // Always merge with local teams to preserve any local-only changes
                self?.loadTeamsFromCloud(mergeWithLocal: true)
            }
            .store(in: &cancellables)
    }
    
    private func loadTeamsFromCloud(mergeWithLocal: Bool = false) {
        CloudKitManager.shared.fetchTeams { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let cloudTeams):
                    if mergeWithLocal {
                        // Combine cloud teams with local teams, preserving any unique teams
                        // from both sources and using the most recent version for duplicates
                        var combinedTeams = self.savedTeams
                        
                        for cloudTeam in cloudTeams {
                            if let index = combinedTeams.firstIndex(where: { $0.id == cloudTeam.id }) {
                                // Team exists in both - use cloud version as it's likely more recent
                                combinedTeams[index] = cloudTeam
                            } else {
                                // Team only in cloud - add it
                                combinedTeams.append(cloudTeam)
                            }
                        }
                        
                        self.savedTeams = combinedTeams
                    } else {
                        // Just use cloud teams directly
                        self.savedTeams = cloudTeams
                    }
                    
                    // Always save the merged teams back to local storage
                    self.saveSavedTeams()
                    
                case .failure:
                    // For failures, we already loaded teams from UserDefaults at app start
                    print("Failed to load from CloudKit, using local teams")
                }
            }
        }
    }
    
    private func loadTeamsFromLocal() {
        if let data = UserDefaults.standard.data(forKey: savedTeamsKey),
           let teams = try? JSONDecoder().decode([SavedTeam].self, from: data) {
            self.savedTeams = teams
        }
    }

    private func setupAutoSave() {
        homeTeam.objectWillChange.sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        awayTeam.objectWillChange.sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        
        // Save when game type changes
        self.objectWillChange.sink { [weak self] _ in
            self?.save()
        }.store(in: &cancellables)
    }

    private func save() {
        let homeCodable = CodableTeam(
            teamName: homeTeam.teamName,
            primaryColor: CodableColor(color: homeTeam.primaryColor),
            secondaryColor: CodableColor(color: homeTeam.secondaryColor),
            fontColor: CodableColor(color: homeTeam.fontColor),
            score: homeTeam.score
        )
        let awayCodable = CodableTeam(
            teamName: awayTeam.teamName,
            primaryColor: CodableColor(color: awayTeam.primaryColor),
            secondaryColor: CodableColor(color: awayTeam.secondaryColor),
            fontColor: CodableColor(color: awayTeam.fontColor),
            score: awayTeam.score
        )
        let savedConfig = SavedConfiguration(
            home: homeCodable, 
            away: awayCodable,
            gameType: currentGameType
        )
        if let data = try? JSONEncoder().encode(savedConfig) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func saveTeam(team: TeamConfiguration, for gameType: GameType) {
        // If this team already has a savedTeamId, use that for updating
        if let existingId = team.savedTeamId,
           let existingIndex = savedTeams.firstIndex(where: { $0.id == existingId }) {
            // Update existing team
            var savedTeam = savedTeams[existingIndex]
            savedTeam.name = team.teamName
            savedTeam.primaryColor = CodableColor(color: team.primaryColor)
            savedTeam.secondaryColor = CodableColor(color: team.secondaryColor)
            savedTeam.fontColor = CodableColor(color: team.fontColor)
            savedTeams[existingIndex] = savedTeam
            
            // ID remains the same since we're updating
        } else {
            // Always create a new saved team with a new UUID when there's no ID
            // or if we can't find the team with the existing ID
            let newSavedTeam = SavedTeam(
                id: UUID(), // Explicitly create a new UUID
                name: team.teamName,
                primaryColor: CodableColor(color: team.primaryColor),
                secondaryColor: CodableColor(color: team.secondaryColor),
                fontColor: CodableColor(color: team.fontColor),
                gameType: gameType
            )
            
            savedTeams.append(newSavedTeam)
            // Update the team's saved ID to the new ID
            team.savedTeamId = newSavedTeam.id
        }
        
        // Save teams in both local storage and cloud
        saveSavedTeams()
        
        // Important: Mark the last saved state to reflect the current state
        // This helps detect future unsaved changes correctly
        team.lastSavedState = TeamSavedState(
            name: team.teamName,
            primaryColor: team.primaryColor.description,
            secondaryColor: team.secondaryColor.description,
            fontColor: team.fontColor.description
        )
        
        // Notify observers that this team has been officially saved
        self.objectWillChange.send()
        team.objectWillChange.send()
    }
    
    func getTeams(for gameType: GameType) -> [SavedTeam] {
        return savedTeams.filter { $0.gameType == gameType }
    }
    
    func updateTeam(_ updatedTeam: SavedTeam) {
        if let index = savedTeams.firstIndex(where: { $0.id == updatedTeam.id }) {
            savedTeams[index] = updatedTeam
            saveSavedTeams()
        }
    }
    
    func deleteTeam(_ teamToDelete: SavedTeam) {
        savedTeams.removeAll { $0.id == teamToDelete.id }
        saveSavedTeams()
    }
    
    private func saveSavedTeams() {
        // Save to UserDefaults as a fallback
        if let data = try? JSONEncoder().encode(savedTeams) {
            UserDefaults.standard.set(data, forKey: savedTeamsKey)
        }
        
        // Save to iCloud if available
        if iCloudAvailable {
            CloudKitManager.shared.saveTeams(savedTeams) { result in
                // If failed, we still have UserDefaults as backup
                if case .failure(let error) = result {
                    print("Failed to save to iCloud: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func refreshTeamsFromCloud() {
        if iCloudAvailable {
            loadTeamsFromCloud(mergeWithLocal: true)
        }
    }
    
    func newGame() {
        homeTeam.score = 0
        awayTeam.score = 0
    }

    func swapTeams() {
        let temp = homeTeam
        homeTeam = awayTeam
        awayTeam = temp
    }
}
