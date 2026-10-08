import SwiftUI

struct RootView: View {
    @State private var showDashboard = false

    var body: some View {
        ZStack {
            if showDashboard {
                MainTabView()     // <-- Your actual tab bar container
            } else {
                LogoRevealView {
                    showDashboard = true
                }
            }
        }
        .animation(.easeOut, value: showDashboard)
    }
}
