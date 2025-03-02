//
//  ScoreboardWidgetBundle.swift
//  ScoreboardWidget
//
//  Created by Craig Sheppard on 2025-03-02.
//

import WidgetKit
import SwiftUI

@main
struct ScoreboardWidgetBundle: WidgetBundle {
    var body: some Widget {
        ScoreboardWidget()
        ScoreboardWidgetControl()
        ScoreboardWidgetLiveActivity()
    }
}
