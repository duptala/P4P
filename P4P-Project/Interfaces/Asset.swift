//
//  Asset.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 26/09/2024.
//
import SwiftUI

// Model for Asset data
struct Asset: Identifiable {
    let id = UUID()
    let name: String
    let level: String
    let room: String
    let lastUpdated: String
    let imageName: String // Name of the image to show on the card
}

