import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var isShowingScanner = false
    @State private var scannedCode: String?
    @State private var statusMessage: String?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.blue, .green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Search + Scan bar
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

                // Show scanned code
                if let code = scannedCode {
                    Text("Scanned: \(code)")
                        .foregroundColor(.white)

                    Button("Save to Firebase") {
                        saveToFirestore(code: code, name: searchText)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)
                }

                // Status feedback
                if let message = statusMessage {
                    Text(message)
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
        }
        // Present scanner full-screen
        .fullScreenCover(isPresented: $isShowingScanner) {
            ScannerView { code in
                scannedCode = code
                isShowingScanner = false
            }
        }
    }

    // MARK: – Firestore write with debug logging
    private func saveToFirestore(code: String, name: String) {
        print("🔄 Attempting to save code=\(code) name=\(name)")
        let db = Firestore.firestore()
        let docRef = db.collection("lab_items").document(code)

        docRef.setData([
            "id": code,
            "name": name.isEmpty ? "Unnamed Item" : name,
            "timestamp": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("❌ Firestore error:", error.localizedDescription)
                DispatchQueue.main.async {
                    statusMessage = "Error saving: \(error.localizedDescription)"
                }
            } else {
                print("✅ Successfully saved to Firestore!")
                DispatchQueue.main.async {
                    statusMessage = "Item “\(code)” saved!"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
