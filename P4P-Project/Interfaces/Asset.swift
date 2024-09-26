//
//  Asset.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 26/09/2024.
//
import SwiftUI

// Model for Asset data
struct Asset: Identifiable {
    let id: String // Firestore document ID
    let name: String
    let code: String // QR Code value for scanning
    let level: String
    let room: String
    let lastUpdatedAt: Date
    let lastUpdatedByName: String
    let lastUpdatedByUPI: String
    let imageUrl: String
}

