//
//  ContentView.swift
//  Lab Tracking
//
//  Created by Vinh Hoang Duc on 5/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var isShowingScanner = false
    @State private var scannedCode: String?

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue, .green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                // Search bar with scan icon
                HStack {
                    TextField("Search...", text: $searchText)
                        .padding(.leading, 12)

                    Button(action: {
                        isShowingScanner = true
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                            .foregroundColor(.black)
                            .font(.system(size: 30))
                            .padding(.trailing, 12)
                    }
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(100)
                .padding(.horizontal)
                .padding(.top, 10)


                // Show scanned result
                if let result = scannedCode {
                    Text("Scanned: \(result)")
                        .foregroundColor(.white)
                        .padding()
                }

                Spacer()
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

#Preview {
    ContentView()
}
