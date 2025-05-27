// ContentView.swift

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var auth: AuthViewModel
  @State private var searchText = ""
  @State private var isShowingScanner = false
  @State private var scannedCode: String?
  @State private var showAddItemView = false
  @State private var newScannedCode: String?
  var body: some View {
    NavigationView {
      ZStack {
        LinearGradient(
          gradient: Gradient(colors: [.blue, .green]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)

        VStack {
          // Search + scan
          HStack {
            TextField("Search…", text: $searchText)
              .padding(.leading, 12)

            Button {
              isShowingScanner = true
            } label: {
              Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 28))
                .padding(.trailing, 12)
            }
          }
          .padding(.vertical, 10)
          .background(Color.white)
          .cornerRadius(50)
          .padding(.horizontal)
          .padding(.top, 10)

          // Show result
          if let code = scannedCode {
            Text("Scanned: \(code)")
              .foregroundColor(.white)
              .padding()
          }

          Spacer()
        }
      }
      .navigationTitle("Lab Tracking")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        // Profile icon (left)
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            // TODO: show profile sheet
          } label: {
            Image(systemName: "person.circle.fill")
              .font(.title2)
              .foregroundColor(.white)
          }
        }

        // Log Out (right)
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Log Out") {
            auth.signOut()
          }
          .foregroundColor(.white)
        }
      }
      .fullScreenCover(isPresented: $isShowingScanner) {
        ScannerView { code in
          scannedCode = code
          isShowingScanner = false
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(AuthViewModel())
  }
}
