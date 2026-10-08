import SwiftUI

@main
struct MomentumApp: App {
    @StateObject private var store = MomentumGoalStore()

    var body: some Scene {
        WindowGroup {
            RootView() 
                .environmentObject(store)
        }
    }
}






