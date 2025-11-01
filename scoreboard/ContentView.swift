import SwiftUI

struct ContentView: View {
    @StateObject var appConfig = AppConfiguration()
    @AppStorage("useRedesignedUI") private var useRedesignedUI = false

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                // Landscape: Show the scoreboard
                ScoreboardView()
                    .environmentObject(appConfig)
            } else {
                // Portrait: Show the configuration view with toggle
                ZStack(alignment: .topTrailing) {
                    if useRedesignedUI {
                        ConfigureViewRedesigned()
                            .environmentObject(appConfig)
                    } else {
                        ConfigureView()
                            .environmentObject(appConfig)
                    }

                    // Toggle button to switch between designs
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            useRedesignedUI.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: useRedesignedUI ? "sparkles" : "sparkles.rectangle.stack")
                                .font(.caption)
                            Text(useRedesignedUI ? "New" : "Classic")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(useRedesignedUI ? Color.purple : Color.blue)
                        .cornerRadius(15)
                        .shadow(color: (useRedesignedUI ? Color.purple : Color.blue).opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 16)
                }
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
