//
//  AssetCardView.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 26/09/2024.
//

import Foundation
import SwiftUI

// Component for each card
struct AssetCardView: View {
    let asset: Asset

    var body: some View {
        HStack {
            // AsyncImage to load the image from the URL
            AsyncImage(url: URL(string: asset.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .padding()
            } placeholder: {
                // Placeholder while loading image
                ProgressView()
                    .frame(width: 50, height: 50)
                    .padding()
            }

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

                // Format the lastUpdatedAt date into a readable string
                Text("Last updated: \(formattedDate(asset.lastUpdatedAt))")
                    .font(.caption)
                    .padding(5)
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(5)
                    .foregroundColor(.gray)

                // "Last edited by" field with editor name and UPI
                Text("Last edited by: \(asset.lastUpdatedByName) / \(asset.lastUpdatedByUPI)")
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
    
    // Function to format the date properly
   func formattedDate(_ date: Date) -> String {
       let formatter = DateFormatter()
       formatter.dateStyle = .medium
       formatter.timeStyle = .short
       return formatter.string(from: date)
   }
}
