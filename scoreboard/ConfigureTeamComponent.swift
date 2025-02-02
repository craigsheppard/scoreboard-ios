import SwiftUI

struct ConfigureTeamComponent: View {
    @ObservedObject var team: TeamConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Team Name", text: $team.teamName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

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
                VStack {
                    Text("Font Color")
                    ColorPicker("", selection: $team.fontColor)
                        .labelsHidden()
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
        ConfigureTeamComponent(team: TeamConfiguration(teamName: "Test", primaryColor: .red, secondaryColor: .blue, fontColor: .white))
            .previewLayout(.sizeThatFits)
    }
}
