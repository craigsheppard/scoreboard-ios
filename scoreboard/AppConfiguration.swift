import SwiftUI
import Combine

final class AppConfiguration: ObservableObject {
    @Published var homeTeam: TeamConfiguration
    @Published var awayTeam: TeamConfiguration
    
    private var cancellables = Set<AnyCancellable>()
    private let storageKey = "AppConfigurationKey"
    
    // Structure for saving both teams together.
    struct SavedConfiguration: Codable {
        let home: CodableTeam
        let away: CodableTeam
    }
    
    init() {
        // Attempt to load saved configuration from local storage.
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let savedConfig = try? JSONDecoder().decode(SavedConfiguration.self, from: data) {
            
            self.homeTeam = TeamConfiguration(
                teamName: savedConfig.home.teamName,
                primaryColor: savedConfig.home.primaryColor.toColor(),
                secondaryColor: savedConfig.home.secondaryColor.toColor(),
                score: savedConfig.home.score
            )
            self.awayTeam = TeamConfiguration(
                teamName: savedConfig.away.teamName,
                primaryColor: savedConfig.away.primaryColor.toColor(),
                secondaryColor: savedConfig.away.secondaryColor.toColor(),
                score: savedConfig.away.score
            )
        } else {
            // If no saved configuration exists, use defaults.
            self.homeTeam = TeamConfiguration(teamName: "Home", primaryColor: .red, secondaryColor: .blue)
            self.awayTeam = TeamConfiguration(teamName: "Away", primaryColor: .blue, secondaryColor: .red)
        }
        
        setupAutoSave()
    }
    
    // Set up subscriptions so that any change in the team configurations triggers a save.
    private func setupAutoSave() {
        homeTeam.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()  // Propagate change upward
                self?.save()
            }
            .store(in: &cancellables)
        
        awayTeam.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()  // Propagate change upward
                self?.save()
            }
            .store(in: &cancellables)
    }
    
    // Save the current configuration to UserDefaults.
    private func save() {
        let homeCodable = CodableTeam(
            teamName: homeTeam.teamName,
            primaryColor: CodableColor(color: homeTeam.primaryColor),
            secondaryColor: CodableColor(color: homeTeam.secondaryColor),
            score: homeTeam.score
        )
        let awayCodable = CodableTeam(
            teamName: awayTeam.teamName,
            primaryColor: CodableColor(color: awayTeam.primaryColor),
            secondaryColor: CodableColor(color: awayTeam.secondaryColor),
            score: awayTeam.score
        )
        let savedConfig = SavedConfiguration(home: homeCodable, away: awayCodable)
        if let data = try? JSONEncoder().encode(savedConfig) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
