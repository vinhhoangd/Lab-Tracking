import SwiftUI
import FirebaseCore

@main
struct Lab_TrackingApp: App {
    init() {
        // 1) Configure Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
