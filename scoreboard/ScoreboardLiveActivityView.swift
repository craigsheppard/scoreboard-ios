import SwiftUI
import WidgetKit
import ActivityKit

struct ScoreboardLiveActivityView: View {
    let context: ActivityViewContext<ScoreboardActivityAttributes>
    
    var body: some View {
        HStack(spacing: 0) {
            // Home Team
            ZStack {
                context.attributes.homeTeamPrimaryColor.toColor()
                
                VStack {
                    OutlinedText(
                        text: "\(context.state.homeTeamScore)",
                        fontName: "JerseyM54",
                        fontSize: 60,
                        textColor: UIColor(context.attributes.homeTeamFontColor.toColor()),
                        strokeColor: UIColor(context.attributes.homeTeamSecondaryColor.toColor()),
                        strokeWidth: -3.0,
                        textAlignment: .center,
                        kern: 2.0
                    )
                    .frame(height: 70)
                    
                    Text(context.attributes.homeTeamName)
                        .font(.caption)
                        .foregroundColor(context.attributes.homeTeamFontColor.toColor())
                        .padding(.top, -8)
                }
                
                // Increase score button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // Button action defined in ActivityHandler
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(context.attributes.homeTeamFontColor.toColor().opacity(0.8))
                                .font(.system(size: 24))
                                .padding(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Away Team
            ZStack {
                context.attributes.awayTeamPrimaryColor.toColor()
                
                VStack {
                    OutlinedText(
                        text: "\(context.state.awayTeamScore)",
                        fontName: "JerseyM54",
                        fontSize: 60,
                        textColor: UIColor(context.attributes.awayTeamFontColor.toColor()),
                        strokeColor: UIColor(context.attributes.awayTeamSecondaryColor.toColor()),
                        strokeWidth: -3.0,
                        textAlignment: .center,
                        kern: 2.0
                    )
                    .frame(height: 70)
                    
                    Text(context.attributes.awayTeamName)
                        .font(.caption)
                        .foregroundColor(context.attributes.awayTeamFontColor.toColor())
                        .padding(.top, -8)
                }
                
                // Increase score button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // Button action defined in ActivityHandler
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(context.attributes.awayTeamFontColor.toColor().opacity(0.8))
                                .font(.system(size: 24))
                                .padding(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .activityBackgroundTint(Color.clear)
        .activitySystemActionForegroundColor(.black)
    }
}