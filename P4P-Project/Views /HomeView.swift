//
//  HomeView.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 26/09/2024.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var name: String // Receiving the name
    var upi: String // Receiving the upi
    @State private var searchText = ""
    
    // Dummy data with asset names, rooms, levels, and last updated time
    let assets = [
        Asset(name: "Air Compressor", level: "Level 7", room: "Room 405-712", lastUpdated: "Just now", imageName: "wrench.fill"),
        Asset(name: "Drill Machine", level: "Level 5", room: "Room 205-302", lastUpdated: "5 mins ago", imageName: "hammer.fill"),
        Asset(name: "Laser Cutter", level: "Level 9", room: "Room 903-122", lastUpdated: "10 mins ago", imageName: "scissors")
    ]
    
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
                    AssetCardView(asset: asset, editorName: name, editorUPI: upi)
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
                    // Action for scan button
                    print("Scan pressed")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.bottom)
        }
        .navigationTitle("Asset Tracker")
    }
}

#Preview {
    HomeView(name: "Test", upi: "ykim583")
}



