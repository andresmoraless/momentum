import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            GoalDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "speedometer")
                }

            ScheduleView()
                .tabItem {
                    Label("Planning", systemImage: "calendar")
                }

            ProgressStatsView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

