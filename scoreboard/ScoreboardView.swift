import SwiftUI
import ActivityKit

struct ScoreboardView: View {
    @EnvironmentObject var appConfig: AppConfiguration
    @EnvironmentObject var liveActivityManager: LiveActivityManager
    @State private var showLiveActivityControls = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                ScoreView(team: appConfig.homeTeam) // Home Team
                ScoreView(team: appConfig.awayTeam) // Away Team
            }
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showLiveActivityControls.toggle()
                    } label: {
                        Image(systemName: "rectangle.inset.filled.and.person.filled")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                }
                
                Spacer()
            }
            
            if showLiveActivityControls {
                liveActivityControlsOverlay
            }
        }
    }
    
    private var liveActivityControlsOverlay: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 15) {
                    if liveActivityManager.isLiveActivitySupported {
                        if liveActivityManager.currentActivity == nil {
                            Button {
                                liveActivityManager.startLiveActivity(appConfig: appConfig)
                                showLiveActivityControls = false
                            } label: {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Start Live Activity")
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.8)))
                                .foregroundColor(.white)
                            }
                        } else {
                            Button {
                                liveActivityManager.updateLiveActivity(appConfig: appConfig)
                                showLiveActivityControls = false
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                    Text("Update Live Activity")
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.8)))
                                .foregroundColor(.white)
                            }
                            
                            Button {
                                liveActivityManager.endLiveActivity()
                                showLiveActivityControls = false
                            } label: {
                                HStack {
                                    Image(systemName: "stop.circle.fill")
                                    Text("End Live Activity")
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.red.opacity(0.8)))
                                .foregroundColor(.white)
                            }
                        }
                    } else {
                        Text("Live Activities not supported on this device")
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.8)))
                    }
                    
                    Button {
                        showLiveActivityControls = false
                    } label: {
                        Text("Close")
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.8)))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.black.opacity(0.7)))
                .padding()
                
                Spacer()
            }
            
            Spacer()
        }
        .transition(.opacity)
        .animation(.easeInOut, value: showLiveActivityControls)
    }
}

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView()
            .environmentObject(AppConfiguration())
            .environmentObject(LiveActivityManager())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
