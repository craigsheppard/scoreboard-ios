import SwiftUI
import Combine

final class AppConfiguration: ObservableObject {
    @Published var homeTeam: TeamConfiguration
    @Published var awayTeam: TeamConfiguration
    
    private var cancellables = Set<AnyCancellable>()
    private let storageKey = "AppConfigurationKey"

    struct SavedConfiguration: Codable {
        let home: CodableTeam
        let away: CodableTeam
    }

    init() {
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
        } else {
            // Default colors when no stored config exists
            self.homeTeam = TeamConfiguration(teamName: "Home", primaryColor: .red, secondaryColor: .blue, fontColor: .white)
            self.awayTeam = TeamConfiguration(teamName: "Away", primaryColor: .blue, secondaryColor: .red, fontColor: .white)
        }

        setupAutoSave()
    }

    private func setupAutoSave() {
        homeTeam.objectWillChange.sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        awayTeam.objectWillChange.sink { [weak self] _ in self?.save() }.store(in: &cancellables)
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
        let savedConfig = SavedConfiguration(home: homeCodable, away: awayCodable)
        if let data = try? JSONEncoder().encode(savedConfig) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
