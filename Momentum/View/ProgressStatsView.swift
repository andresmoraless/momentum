import SwiftUI

struct ProgressStatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.8))

            Text("Progress Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)

            Text("We're building something great for you!")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

