import SwiftUI

struct ConfigureTeamComponent: View {
    @ObservedObject var team: TeamConfiguration
    @State private var showScoreAdjusters: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Team name input
            TextField("Team Name", text: $team.teamName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Color pickers for primary and secondary colours
            HStack {
                VStack {
                    Text("Primary Color")
                    ColorPicker("", selection: $team.primaryColor)
                        .labelsHidden()
                }
                VStack {
                    Text("Secondary Color")
                    ColorPicker("", selection: $team.secondaryColor)
                        .labelsHidden()
                }
            }
            
            // Score display using outlined Jersey font; tap to toggle score adjusters
            VStack(alignment: .leading) {
                OutlinedText(
                    text: "\(team.score)",
                    fontName: "JerseyM54",   // Use your actual internal font name
                    fontSize: 40,
                    textColor: .white,
                    strokeColor: UIColor(team.secondaryColor),
                    strokeWidth: -2.0,
                    textAlignment: .center,
                    kern: 1.0              // Adjust kerning for small text if desired
                )
                .contentShape(Rectangle())  // Ensure the full area is tappable
                .onTapGesture {
                    withAnimation {
                        showScoreAdjusters.toggle()
                    }
                }
                
                if showScoreAdjusters {
                    HStack {
                        Button(action: { team.score -= 1 }) {
                            Text("-")
                                .font(.largeTitle)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        Button(action: { team.score += 1 }) {
                            Text("+")
                                .font(.largeTitle)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary, lineWidth: 1))
        .padding()
    }
}

struct ConfigureTeamComponent_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureTeamComponent(team: TeamConfiguration(teamName: "Test", primaryColor: .red, secondaryColor: .blue))
            .previewLayout(.sizeThatFits)
    }
}
