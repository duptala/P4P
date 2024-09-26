//
//  BLEManager.swift
//  P4P-Project
//
//  Created by Devesh Duptala on 27/09/2024.
//

import Foundation
import CoreBluetooth

// Define the PeripheralInfo struct to store BLE info
struct PeripheralInfo: Identifiable {
    let id = UUID()
    let identifier: String
    let name: String
    var rssi: Int
    var rssiValues: [Int] = []

    mutating func updateRSSI(_ newRSSI: Int) {
        if rssiValues.count >= 7 {
            rssiValues.removeFirst()
        }
        rssiValues.append(newRSSI)
        // Calculate average RSSI for more stable readings
        self.rssi = rssiValues.reduce(0, +) / rssiValues.count
    }
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    // BLE properties
    private var centralManager: CBCentralManager!
    @Published var detectedRoom: String = "Undetermined room" // Publish detected room
    private var discoveredPeripherals: [PeripheralInfo] = []
    private var timer: Timer?

    override init() {
        super.init()
#if !targetEnvironment(simulator)
        centralManager = CBCentralManager(delegate: self, queue: nil)
#endif
    }

    // Start scanning for BLE peripherals
    func startScanning() {
#if !targetEnvironment(simulator)
        guard centralManager.state == .poweredOn else {
            print("Bluetooth is not powered on. Cannot start scanning.")
            return
        }
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        // Set a timer to re-scan every second and update room detection
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            self.updateDetectedRoom() // Update room based on RSSI
        }
#endif
    }
    
    // Stop scanning for BLE peripherals
    func stopScanning() {
#if !targetEnvironment(simulator)
        centralManager.stopScan()
        timer?.invalidate()
        timer = nil
#endif
    }
    
    // Bluetooth state change handling
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
#if !targetEnvironment(simulator)
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth state changed to: \(central.state.rawValue)")
        }
#endif
    }
    
    // When BLE devices are discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let identifier = peripheral.identifier.uuidString
        let name = peripheral.name ?? "Unknown"
        
        // Filter only the devices of interest (e.g., "1", "2", "3", "4", "5")
        guard ["1", "2", "3", "4", "5"].contains(name) else { return }
        
        if let index = discoveredPeripherals.firstIndex(where: { $0.identifier == identifier }) {
            // Update the RSSI value for an existing device
            discoveredPeripherals[index].updateRSSI(RSSI.intValue)
        } else {
            // Add new device
            let peripheralInfo = PeripheralInfo(identifier: identifier, name: name, rssi: RSSI.intValue)
            discoveredPeripherals.append(peripheralInfo)
        }
        
        // Trigger room update after processing peripherals
        updateDetectedRoom()
    }

    // Function to determine the room based on the two strongest RSSI values
    func updateDetectedRoom() {
        // Sort peripherals by RSSI (strongest first)
        let sortedPeripherals = discoveredPeripherals.sorted { $0.rssi > $1.rssi }
        
        // We need at least two peripherals to determine the room
        guard sortedPeripherals.count >= 2 else {
            detectedRoom = "Undetermined room"
            return
        }
        
        // Get the names of the top two peripherals with the highest RSSI
        let topTwoPeripherals = sortedPeripherals.prefix(2)
        let firstBeacon = topTwoPeripherals[0].name
        let secondBeacon = topTwoPeripherals[1].name
        
        // Determine the room based on the two strongest signals
        detectedRoom = determineRoom(firstBeacon: firstBeacon, secondBeacon: secondBeacon)
    }

    // Map the two strongest beacons to specific rooms
    private func determineRoom(firstBeacon: String, secondBeacon: String) -> String {
        switch (firstBeacon, secondBeacon) {
        case ("1", "2"), ("2", "1"):
            return "Room 405-712"
        case ("2", "3"), ("3", "2"):
            return "Room 405-722"
        case ("3", "4"), ("4", "3"):
            return "Room 405-722"
        case ("2", "4"), ("4", "2"):
            return "Room 405-722" // Same as above for large room
        case ("4", "5"), ("5", "4"):
            return "Room 405-736"
        default:
            return "Undetermined room"
        }
    }
}

