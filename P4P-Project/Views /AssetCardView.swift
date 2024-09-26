//
//  AssetCardView.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 26/09/2024.
//

import Foundation
import SwiftUI
import SwiftUI

// Component for each card
struct AssetCardView: View {
    let asset: Asset
    let editorName: String // New field for editor's name
    let editorUPI: String  // New field for editor's UPI

    var body: some View {
        HStack {
            // Image on the left side
            Image(systemName: asset.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()

            VStack(alignment: .leading, spacing: 10) {
                // Asset name (large)
                Text(asset.name)
                    .font(.title3) // Make the asset name bigger
                    .fontWeight(.bold) // Make the asset name bold
                    .foregroundColor(.primary) // Primary color (usually black/dark)

                // Location (separate from room)
                Text("Location: \(asset.level)")
                    .font(.subheadline) // Slightly smaller for secondary info
                    .foregroundColor(.secondary) // Secondary color (usually gray)
                
                Text("Room: \(asset.room)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Last updated with different background and padding
                Text("Last updated: \(asset.lastUpdated)")
                    .font(.caption) // Small text
                    .padding(5)
                    .background(Color.yellow.opacity(0.3)) // Soft yellow background
                    .cornerRadius(5)
                    .foregroundColor(.gray)

                // New "Last edited by" field with editor name and UPI
                Text("Last edited by: \(editorName) / \(editorUPI)")
                    .font(.caption) // Small text
                    .foregroundColor(.gray) // Gray text for less emphasis
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray5)) // Background color of the card
        .cornerRadius(15) // More rounded corners
        .shadow(radius: 2)
        .padding(.horizontal)
        .padding(.vertical, 8) // More padding around the card
    }
}

