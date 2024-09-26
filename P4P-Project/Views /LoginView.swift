//
//  LoginView.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 26/09/2024.
//

import SwiftUI

// Login View
struct LoginView: View {
    @State private var name: String = "" // State to hold entered name
    @State private var upi: String = "" // State to hold entered name

    var body: some View {
        VStack {
            Text("ECSE Asset Tracker")
                .font(.largeTitle)
                .padding()

            TextField("Enter your name", text: $name)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            TextField("Enter your UPI", text: $upi)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            NavigationLink(destination: HomeView(name: name, upi: upi)) {
                Text("Enter")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .disabled(name.isEmpty) // Disable the button if the name is empty
        }
        .padding()
    }
}

