// AuthViewModel.swift

import Foundation
import FirebaseAuth
import Combine

/// Manages the current Firebase user and exposes sign-in / sign-out methods.
class AuthViewModel: ObservableObject {
  
  @Published var user: User?         // FirebaseAuth.User
  @ublished var isLoading = false   // optional: show a spinner
  
  private var handle: AuthStateDidChangeListenerHandle?

  init() {
    // Watch for auth changes
    handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      self?.user = user
    }
  }
  
  deinit {
    if let h = handle {
      Auth.auth().removeStateDidChangeListener(h)
    }
  }
  
  /// Create a new account with email & password
  func signUp(email: String, password: String, completion: @escaping (Result<User,Error>) -> Void) {
    isLoading = true
    Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
      DispatchQueue.main.async {
        self?.isLoading = false
        if let err = error { return completion(.failure(err)) }
        if let user = result?.user { return completion(.success(user)) }
      }
    }
  }
  
  /// Sign in an existing user
  func signIn(email: String, password: String, completion: @escaping (Result<User,Error>) -> Void) {
    isLoading = true
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
      DispatchQueue.main.async {
        self?.isLoading = false
        if let err = error { return completion(.failure(err)) }
        if let user = result?.user { return completion(.success(user)) }
      }
    }
  }
  
  /// Sign out the current user
  func signOut() {
    do {
      try Auth.auth().signOut()
      self.user = nil
    } catch {
      print("⚠️ Failed to sign out:", error.localizedDescription)
    }
  }
}
