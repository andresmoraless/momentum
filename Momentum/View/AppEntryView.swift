import SwiftUI

struct AppEntryView: View {
    @State private var showLogo = true

    var body: some View {
        ZStack {
            if showLogo {
                LogoRevealView {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showLogo = false
                    }
                }
                .transition(.opacity.combined(with: .scale))
            } else {
                GoalDashboardView()   // ← your normal main dashboard
                    .transition(.opacity)
            }
        }
    }
}



