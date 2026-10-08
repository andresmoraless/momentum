import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: MomentumGoalStore

    var body: some View {
        NavigationView {
            Form {
                Section("Visuals") {
                    Toggle("Show Confetti", isOn: $store.preferences.showConfetti)
                    Toggle("Show Glow", isOn: $store.preferences.showGlow)
                    Toggle("Encouragement Messages", isOn: $store.preferences.showEncouragements)
                }

                Section("About") {
                    Text("Momentum v1.0")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

