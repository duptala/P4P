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
    var name: String // Receiving the name
    var upi: String // Receiving the upi
    @State private var searchText = ""
    @State private var isPresentingScanner = false // State to show the QR scanner
    @State private var scannedCode = "" // State to store the scanned QR code
    @State private var assets: [Asset] = [] // Array to store retrieved assets
        
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

            // Scrollable list of cards
            ScrollView {
                ForEach(filteredAssets) { asset in
                    AssetCardView(asset: asset)
                }
            }
            
            // User details
            Text("Currently logged in as: " + name + " | " + upi)
                .padding()
                .font(.caption)
                .foregroundColor(.gray)
            
            // BLE beacon detection placeholder
            Text("Room: 405-712") // Placeholder for BLE detection
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            // Bottom navbar with scan button
            HStack {
                Button("Scan") {
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
        .onChange(of: scannedCode) { newCode in
            if !newCode.isEmpty {
                // Fetch the asset from Firestore after scanning the QR code
                fetchAssetByQRCode(qrCode: newCode)
            }
        }
    }
    
    // Function to fetch an asset by QR code from Firestore
    func fetchAssetByQRCode(qrCode: String) {
        let db = Firestore.firestore()
        db.collection("assets").whereField("code", isEqualTo: qrCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching asset: \(error)")
            } else if let document = snapshot?.documents.first {
                let data = document.data()
                let asset = Asset(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    code: data["code"] as? String ?? "",
                    level: data["level"] as? String ?? "",
                    room: data["room"] as? String ?? "",
                    lastUpdatedAt: data["lastUpdatedAt"] as? String ?? "",
                    lastUpdatedByName: data["lastUpdatedByName"] as? String ?? "",
                    lastUpdatedByUPI: data["lastUpdatedByName"] as? String ?? "",
                    imageUrl: data["imageUrl"] as? String ?? ""
                )
                // Add the retrieved asset to the list
                self.assets.append(asset)
            }
        }
    }
}



