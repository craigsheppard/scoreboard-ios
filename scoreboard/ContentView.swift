import SwiftUI

struct ContentView: View {
    @StateObject var appConfig = AppConfiguration()
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Landscape: Show the scoreboard
                ScoreboardView()
                    .environmentObject(appConfig)
            } else {
                // Portrait: Show the configuration view
                ConfigureView()
                    .environmentObject(appConfig)
            }
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewInterfaceOrientation(.landscapeLeft)
            ContentView()
                .previewInterfaceOrientation(.portrait)
        }
    }
}
