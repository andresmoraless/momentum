import SwiftUI

struct CompletionToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .shadow(radius: 4)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: message)
    }
}

