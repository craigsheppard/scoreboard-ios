import SwiftUI

struct ConfigureView: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Home Team")
                        .font(.headline)
                    ConfigureTeamComponent()
                }
                VStack {
                    Text("Away Team")
                        .font(.headline)
                    ConfigureTeamComponent()
                }
            }
            Spacer()
            Button(action: {
                // Force landscape orientation so that the ScoreboardView appears.
                // Note: This approach is a hack and may need extra handling.
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            }) {
                Text("Go")
                    .font(.largeTitle)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}

struct ConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureView()
            .previewInterfaceOrientation(.portrait)
    }
}