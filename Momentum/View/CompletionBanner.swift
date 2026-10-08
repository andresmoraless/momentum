import SwiftUI

struct CompletionBanner: View {
    let message: String
    let color: Color
    
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible {
            VStack {
                Spacer()
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(color)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
                    .padding(.bottom, 90) // sits above the tab bar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isVisible)
            }
            .ignoresSafeArea()
        }
    }
}

