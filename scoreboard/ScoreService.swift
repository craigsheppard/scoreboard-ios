import Foundation
import Combine

final class ScoreService: ObservableObject {
    @Published var leftScore: Int = 0
    @Published var rightScore: Int = 0

    func increaseLeftScore() {
        leftScore += 1
    }

    func increaseRightScore() {
        rightScore += 1
    }
}