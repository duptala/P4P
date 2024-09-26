//
//  AssetDetailView.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 27/09/2024.
//

import SwiftUI
import FirebaseFirestore

struct AssetDetailView: View {
    let asset: Asset
    var name: String // Current user's name
    var upi: String // Current user's UPI
    var updateAsset: (Asset) -> Void // Function to update specific asset in HomeView
    @State private var isMoving = false // Tracks if the item is being moved
    @State private var showAlert = false // State to show alert
    @State private var alertMessage = "" // Message for the alert

    var body: some View {
        VStack {
            // Display asset image
            AsyncImage(url: URL(string: asset.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            } placeholder: {
                ProgressView()
            }
            
            // Display asset details
            Text(asset.name)
                .font(.title)
                .fontWeight(.bold)
            Text("Location: \(asset.level), \(asset.room)")
            Text("Last updated by: \(asset.lastUpdatedByName) / \(asset.lastUpdatedByUPI)")
            Text("Last updated at: \(formattedDate(asset.lastUpdatedAt))")
            
            if isMoving {
                // If moving, only show "Finish Moving" button
                Button("Finish Moving") {
                    finishMoving()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                // "Move" button
                Button("Move") {
                    startMoving()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        // Display an alert if the operation is successful or fails
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Operation Status"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // Start moving: disable other functionality, show "Finish Moving"
    func startMoving() {
        isMoving = true
    }
    
    // Finish moving: update asset in the database, refresh, and show alert
    func finishMoving() {
        // Example: Update the asset’s new room (using BLE)
        let newRoom = detectNewRoom() // Replace with BLE detection logic
        
        // Update Firestore
        let db = Firestore.firestore()
        db.collection("assets").document(asset.id).updateData([
            "room": newRoom,
            "lastUpdatedAt": Date(),
            "lastUpdatedByName": name,
            "lastUpdatedByUPI": upi
        ]) { error in
            if let error = error {
                // Show failure alert
                alertMessage = "Failed to update asset: \(error.localizedDescription)"
            } else {
                // Create updated asset
                let updatedAsset = Asset(
                    id: asset.id,
                    name: asset.name,
                    code: asset.code,
                    level: asset.level,
                    room: newRoom, // Update room
                    lastUpdatedAt: Date(), // Update time
                    lastUpdatedByName: name,
                    lastUpdatedByUPI: upi,
                    imageUrl: asset.imageUrl
                )
                // Call updateAsset to update the specific asset in HomeView
                updateAsset(updatedAsset)
                
                // Show success alert
                alertMessage = "Asset successfully updated!"
            }
            showAlert = true // Show the alert after the operation
            isMoving = false // Reset the moving state
        }
    }

    // Dummy BLE detection function for room change
    func detectNewRoom() -> String {
        return "New Room Detected via BLE"
    }

    // Function to format the date
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
