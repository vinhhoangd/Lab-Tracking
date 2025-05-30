// AuthViewModel.swift

import Foundation
import FirebaseAuth
import Combine
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

class AuthViewModel: ObservableObject {
  
  @Published var user: User?         // FirebaseAuth.User
  @Published var isLoading = false   // optional: show a spinner
  
  private var handle: AuthStateDidChangeListenerHandle?

  init() {

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
      print("Failed to sign out:", error.localizedDescription)
    }
  }
        
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "SignInError", code: -1)))
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                } else if let user = result?.user {
                    completion(.success(user))
                }
            }
        }
    }
}
