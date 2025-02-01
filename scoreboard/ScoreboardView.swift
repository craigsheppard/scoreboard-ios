import SwiftUI

struct ScoreboardView: View {
    @StateObject private var scoreService = ScoreService()
    
    var body: some View {
        HStack(spacing: 0) {
            // Left half – red background
            ZStack {
                Color.red
                Text("\(scoreService.leftScore)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                scoreService.increaseLeftScore()
            }
            
            // Right half – blue background
            ZStack {
                Color.blue
                Text("\(scoreService.rightScore)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                scoreService.increaseRightScore()
            }
        }
        .ignoresSafeArea()
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}