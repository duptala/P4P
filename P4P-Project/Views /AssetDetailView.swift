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
    @State private var isMoving = false // Tracks if the item is being moved
    
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
            Text("Last updated at: \(asset.lastUpdatedAt)")
            
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
    }
    
    // Start moving: disable other functionality, show "Finish Moving"
    func startMoving() {
        isMoving = true
        // Lock other functionalities if needed
    }
    
    // Finish moving: update asset in the database
    func finishMoving() {
        // Example: Update the asset’s new room (using BLE)
        let newRoom = detectNewRoom() // Replace with BLE detection logic
        
        // Update Firestore
        let db = Firestore.firestore()
        db.collection("assets").document(asset.id).updateData([
            "room": newRoom,
            "lastUpdatedAt": Date().description,
            "lastUpdatedByName": name,
            "lastUpdatedByUPI": upi
        ]) { error in
            if let error = error {
                print("Error updating asset: \(error)")
            } else {
                print("Asset successfully updated")
                isMoving = false
            }
        }
    }
    
    // Dummy BLE detection function for room change
    func detectNewRoom() -> String {
        return "New Room Detected via BLE"
    }
}
