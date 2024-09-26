//
//  qr.swift
//  P4P-Project
//
//  Created by Youngmin Kim on 26/09/24.
//

import SwiftUI
import CodeScanner

struct QRScannerView: View {
    @Binding var isPresentingScanner: Bool
    @Binding var scannedCode: String

    var body: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                switch result {
                case .success(let code):
                    self.scannedCode = code.string
                    self.isPresentingScanner = false
                    saveScannedData(code: code.string)
                case .failure(let error):
                    self.scannedCode = "Scanning failed: \(error.localizedDescription)"
                    self.isPresentingScanner = false
                }
            }
        )
    }

    func saveScannedData(code: String) {
        print("Code to be saved: \(code)")
        
        do {
            // Get the path to the shared Documents directory
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                // Create a file path within the shared Documents directory
                let filePath = documentsDirectory.appendingPathComponent("scannedData.json")
                
                // Create a new scanned data object
                let newScannedData = ScannedData(code: code, date: Date())
                
                var scannedDataArray: [ScannedData] = []
                
                // Check if the file already exists
                if FileManager.default.fileExists(atPath: filePath.path) {
                    // Read the existing data
                    let existingData = try Data(contentsOf: filePath)
                    let decoder = JSONDecoder()
                    scannedDataArray = try decoder.decode([ScannedData].self, from: existingData)
                }
                
                // Append the new scanned data
                scannedDataArray.append(newScannedData)
                
                // Encode the array back to JSON
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(scannedDataArray)
                
                // Save the data to the file
                try data.write(to: filePath)
                print("Saved data to \(filePath)")
            }
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
}

struct ScannedData: Codable {
    let code: String
    let date: Date
}

