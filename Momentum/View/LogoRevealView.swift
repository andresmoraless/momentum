import SwiftUI

struct LogoRevealView: View {
    @State private var progress: CGFloat = 0
    var onFinished: () -> Void

    var body: some View {
        LogoMShape()
            .trim(from: 0, to: progress)
            .stroke(
                Color.blue,
                style: StrokeStyle(
                    lineWidth: 30,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: 320, height: 400)
            .padding(40)
            .animation(.easeOut(duration: 1.4), value: progress)
            .task {
                progress = 1.0

                // Fire after animation finishes
                try? await Task.sleep(nanoseconds: 1_400_000_000)
                onFinished()
            }
    }
}







