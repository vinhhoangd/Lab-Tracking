// Lab_TrackingApp.swift
import GoogleSignIn
import SwiftUI
import FirebaseCore

@main
struct Lab_TrackingApp: App {
  @StateObject private var auth = AuthViewModel()
  
  init() {
    FirebaseApp.configure()
  }
  
  var body: some Scene {
    WindowGroup {
      Group {
        if auth.user == nil {
          // Not signed in
          LoginView()
        } else {
          // Signed in
          ContentView()
        }
      }
      .environmentObject(auth)
    }
  }
}
