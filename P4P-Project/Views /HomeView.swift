//
//  HomeView.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 26/09/2024.
//

import SwiftUI
import CodeScanner
import FirebaseFirestore

struct HomeView: View {
    var name: String // User's name
    var upi: String // User's UPI
    @State private var searchText = ""
    @State private var isPresentingScanner = false // State to show the QR scanner
    @State private var scannedCode = "" // State to store the scanned QR code
    @State private var assets: [Asset] = [] // Array to store retrieved assets
    @State private var selectedAsset: Asset? // Stores the asset selected after scanning
    
    // State variable to control the color of the room detection text
    @State private var isBlinking = false
        
    // Firestore instance
    let db = Firestore.firestore()
    
    // Filtered list of assets based on search text
    var filteredAssets: [Asset] {
        if searchText.isEmpty {
            return assets
        } else {
            return assets.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack {
            // Search Bar
            TextField("Search assets", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            // Scrollable list of cards displaying assets
            ScrollView {
                ForEach(filteredAssets) { asset in
                    AssetCardView(asset: asset)
                }
            }
            
            // Room detected with blinking effect
            Text("Room detected: TODO:REPL")
                .font(.caption)
                .foregroundColor(isBlinking ? .gray : .black) // Blink effect
                .animation(.linear(duration: 0.5).repeatForever(), value: isBlinking) // Blinking animation
            
            Spacer()
            
            // User details
            Text("Logged in as: \(name) | \(upi)")
                .padding()
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            // Bottom navbar with scan button
            HStack {
                Button("Scan to Move") {
                    // Show QR Scanner when the button is pressed
                    isPresentingScanner = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.bottom)
        }
        .navigationTitle("Asset Tracker")
        .sheet(isPresented: $isPresentingScanner) {
            // QR Scanner View
            QRScannerView(isPresentingScanner: $isPresentingScanner, scannedCode: $scannedCode)
        }
        .sheet(item: $selectedAsset) { asset in
            // When an asset is selected after scanning, navigate to the AssetDetailView
            AssetDetailView(asset: asset, name: name, upi: upi, updateAsset: updateAsset)
        }
        .onAppear {
            // Fetch all assets when the view appears
            fetchAllAssets()
            
            // Start the blinking animation on appear
            startBlinking()
        }
        .onChange(of: scannedCode) { newCode in
            if !newCode.isEmpty {
                // Fetch the asset from Firestore after scanning the QR code
                fetchAssetByQRCode(qrCode: newCode)
                
                // Reset isPresentingScanner to false so the scanner can be triggered again
                isPresentingScanner = false
                
                // Reset the scanned code to allow for future scans
                scannedCode = "" // This line is important for resetting the scanned state
            }
        }
    }
    
    // Function to control the blinking effect
        func startBlinking() {
            // A timer that will repeat the blinking effect
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                isBlinking.toggle()
            }
        }
    
    // Function to update the specific asset in the assets array
    func updateAsset(_ updatedAsset: Asset) {
        if let index = assets.firstIndex(where: { $0.id == updatedAsset.id }) {
            assets[index] = updatedAsset // Update the specific asset in the array
        }
    }
    
    // Function to fetch an asset by QR code from Firestore
    func fetchAssetByQRCode(qrCode: String) {
        db.collection("assets").whereField("code", isEqualTo: qrCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching asset: \(error)")
            } else if let document = snapshot?.documents.first {
                let data = document.data()
                
                // fetching the Timestamp and convert it to Date
                let timestamp = data["lastUpdatedAt"] as? Timestamp
                let lastUpdatedAt = timestamp?.dateValue() ?? Date() // Default to current date if nil
                
                let asset = Asset(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    code: data["code"] as? String ?? "",
                    level: data["level"] as? String ?? "",
                    room: data["room"] as? String ?? "",
                    lastUpdatedAt: lastUpdatedAt,
                    lastUpdatedByName: data["lastUpdatedByName"] as? String ?? "",
                    lastUpdatedByUPI: data["lastUpdatedByUPI"] as? String ?? "",
                    imageUrl: data["imageUrl"] as? String ?? ""
                )
                self.selectedAsset = asset // Navigate to AssetDetailView
            }
        }
    }

    // Function to fetch all assets from Firestore
    func fetchAllAssets() {
        db.collection("assets").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching assets: \(error)")
            } else if let snapshot = snapshot {
                // Clear the existing list of assets and add the new ones
                self.assets = snapshot.documents.compactMap { document in
                    let data = document.data()
                    
                    // fetching the Timestamp and convert it to Date
                    let timestamp = data["lastUpdatedAt"] as? Timestamp
                    let lastUpdatedAt = timestamp?.dateValue() ?? Date() // Default to current date if nil
                    
                    return Asset(
                        id: document.documentID,
                        name: data["name"] as? String ?? "",
                        code: data["code"] as? String ?? "",
                        level: data["level"] as? String ?? "",
                        room: data["room"] as? String ?? "",
                        lastUpdatedAt: lastUpdatedAt,
                        lastUpdatedByName: data["lastUpdatedByName"] as? String ?? "",
                        lastUpdatedByUPI: data["lastUpdatedByUPI"] as? String ?? "",
                        imageUrl: data["imageUrl"] as? String ?? ""
                    )
                }
            }
        }
    }
}
