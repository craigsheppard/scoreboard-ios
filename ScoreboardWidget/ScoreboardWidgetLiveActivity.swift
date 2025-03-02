//
//  ScoreboardWidgetLiveActivity.swift
//  ScoreboardWidget
//
//  Created by Craig Sheppard on 2025-03-02.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ScoreboardWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ScoreboardWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ScoreboardWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ScoreboardWidgetAttributes {
    fileprivate static var preview: ScoreboardWidgetAttributes {
        ScoreboardWidgetAttributes(name: "World")
    }
}

extension ScoreboardWidgetAttributes.ContentState {
    fileprivate static var smiley: ScoreboardWidgetAttributes.ContentState {
        ScoreboardWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ScoreboardWidgetAttributes.ContentState {
         ScoreboardWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ScoreboardWidgetAttributes.preview) {
   ScoreboardWidgetLiveActivity()
} contentStates: {
    ScoreboardWidgetAttributes.ContentState.smiley
    ScoreboardWidgetAttributes.ContentState.starEyes
}
