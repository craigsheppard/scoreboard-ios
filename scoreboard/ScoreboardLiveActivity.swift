import ActivityKit
import WidgetKit
import SwiftUI

// Removed @main to avoid the conflict with scoreboardApp

struct ScoreboardLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScoreboardActivityAttributes.self) { context in
            // The dynamic content that will be shown in the Live Activity
            ScoreboardLiveActivityView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island configuration
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Text(context.attributes.homeTeamName)
                            .font(.caption)
                            .foregroundColor(context.attributes.homeTeamFontColor.toColor())
                        Spacer()
                        Text("\(context.state.homeTeamScore)")
                            .font(.title)
                            .foregroundColor(context.attributes.homeTeamFontColor.toColor())
                            .fontWeight(.bold)
                    }
                    .padding(.leading, 8)
                    .background(context.attributes.homeTeamPrimaryColor.toColor())
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Text("\(context.state.awayTeamScore)")
                            .font(.title)
                            .foregroundColor(context.attributes.awayTeamFontColor.toColor())
                            .fontWeight(.bold)
                        Spacer()
                        Text(context.attributes.awayTeamName)
                            .font(.caption)
                            .foregroundColor(context.attributes.awayTeamFontColor.toColor())
                    }
                    .padding(.trailing, 8)
                    .background(context.attributes.awayTeamPrimaryColor.toColor())
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text("VS")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Button {
                            // Increment home team score
                        } label: {
                            Label("Home +1", systemImage: "plus.circle")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                        Button {
                            // Increment away team score
                        } label: {
                            Label("Away +1", systemImage: "plus.circle")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Text(context.attributes.homeTeamName.prefix(1))
                        .foregroundColor(context.attributes.homeTeamFontColor.toColor())
                    Text("\(context.state.homeTeamScore)")
                        .foregroundColor(context.attributes.homeTeamFontColor.toColor())
                        .fontWeight(.bold)
                }
                .padding(.leading, 4)
                .background(context.attributes.homeTeamPrimaryColor.toColor())
            } compactTrailing: {
                HStack(spacing: 4) {
                    Text("\(context.state.awayTeamScore)")
                        .foregroundColor(context.attributes.awayTeamFontColor.toColor())
                        .fontWeight(.bold)
                    Text(context.attributes.awayTeamName.prefix(1))
                        .foregroundColor(context.attributes.awayTeamFontColor.toColor())
                }
                .padding(.trailing, 4)
                .background(context.attributes.awayTeamPrimaryColor.toColor())
            } minimal: {
                Text("\(context.state.homeTeamScore) - \(context.state.awayTeamScore)")
                    .fontWeight(.bold)
            }
            .keylineTint(Color.gray)
        }
    }
}