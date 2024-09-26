//
//  WelcomeView.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 26/09/2024.
//

import Foundation
import SwiftUI

// Next Screen (Welcome View)
struct WelcomeView: View {
    var name: String // Receiving the name

    var body: some View {
        VStack {
            Text("Welcome, \(name)!")
                .font(.largeTitle)
                .padding()

            // Placeholder for future backend data handling
            Text("This will be where we push data to the backend.")
                .padding()
        }
    }
}
