// LoginView.swift
import GoogleSignIn
import SwiftUI
import FirebaseAuth
import FirebaseCore

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSignUpMode = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isSignUpMode ? "Create Account" : "Sign In")
                .font(.largeTitle)
                .bold()
            
            Group {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
            
            Button(action: handleAuth) {
                HStack {
                    Spacer()
                    Text(isSignUpMode ? "Sign Up" : "Log In")
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                    Spacer()
                }
                .background(Color.blue)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            .disabled(email.isEmpty || password.isEmpty || auth.isLoading)
            
            Button(isSignUpMode ? "Already have an account? Log In" : "Create new account") {
                isSignUpMode.toggle()
            }
            .padding(.top)
            .font(.footnote)
            
            Button(action: handleGoogleSignIn) {
                HStack {
                    Image(systemName: "globe")
                    Text("Sign in with Google")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 60)
        .alert(isPresented: $showingErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .overlay(
            Group {
                if auth.isLoading {
                    ProgressView().scaleEffect(1.5)
                }
            }
        )
    }
    
    private func handleAuth() {
        let _: () = isSignUpMode
        ? auth.signUp(email: email, password: password) { result in onAuthResult(result) }
        : auth.signIn(email: email, password: password) { result in onAuthResult(result) }
    }
    
    private func onAuthResult(_ result: Result<User,Error>) {
        switch result {
        case .success:
            break
        case .failure(let err):
            errorMessage = err.localizedDescription
            showingErrorAlert = true
        }
    }
    
    private func handleGoogleSignIn() {
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first else {
            print("Cannot find root view controller")
            return
        }
        
        Task {
            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
                guard let idToken = result.user.idToken?.tokenString else {
                    print("No ID Token found")
                    return
                }
                
                let accessToken = result.user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                try await Auth.auth().signIn(with: credential)
                print("Signed in with Google")
            } catch {
                print("Google Sign-In Error: \(error.localizedDescription)")
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView().environmentObject(AuthViewModel())
  }
}
