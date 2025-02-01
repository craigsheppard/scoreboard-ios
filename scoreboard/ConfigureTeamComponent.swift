import SwiftUI

struct ConfigureTeamComponent: View {
    @State private var teamName: String = ""
    @State private var primaryColor: Color = .red
    @State private var secondaryColor: Color = .blue
    @State private var score: Int = 0
    @State private var showScoreAdjusters: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Team name input
            TextField("Team Name", text: $teamName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Color pickers for primary and secondary colors
            HStack {
                VStack {
                    Text("Primary Color")
                    ColorPicker("", selection: $primaryColor)
                        .labelsHidden()
                }
                VStack {
                    Text("Secondary Color")
                    ColorPicker("", selection: $secondaryColor)
                        .labelsHidden()
                }
            }
            
            // Score display – tap to reveal adjusters
            VStack(alignment: .leading) {
                Text("Score: \(score)")
                    .font(.title)
                    .onTapGesture {
                        withAnimation {
                            showScoreAdjusters.toggle()
                        }
                    }
                
                if showScoreAdjusters {
                    HStack {
                        Button(action: { score -= 1 }) {
                            Text("-")
                                .font(.largeTitle)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        Button(action: { score += 1 }) {
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
        ConfigureTeamComponent()
    }
}