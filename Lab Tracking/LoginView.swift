// LoginView.swift

import SwiftUI
import FirebaseAuth
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
      
      Spacer()
    }
    .padding(.top, 60)
    .alert(isPresented: $showingErrorAlert) {
      Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
    }
    .overlay(
      // optional loading spinner
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
      break  // AuthViewModel’s listener will flip us into ContentView
    case .failure(let err):
      errorMessage = err.localizedDescription
      showingErrorAlert = true
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView().environmentObject(AuthViewModel())
  }
}
