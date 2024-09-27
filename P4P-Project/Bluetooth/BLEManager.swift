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
    @Published var debugLogs: [String] = [] // Store debug logs
    
    private var lastDetectedRoom: String = "Room 405-712" // Last valid detected room
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
            logDebug("Bluetooth is not powered on. Cannot start scanning.")
            return
        }
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        logDebug("Started BLE scanning.")
        
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
        logDebug("Stopped BLE scanning.")
#endif
    }
    
    // Bluetooth state change handling
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
#if !targetEnvironment(simulator)
        if central.state == .poweredOn {
            startScanning()
        } else {
            logDebug("Bluetooth state changed to: \(central.state.rawValue)")
        }
#endif
    }
    
    // When BLE devices are discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let identifier = peripheral.identifier.uuidString
        let name = peripheral.name ?? "Unknown"
        
        logDebug("Discovered peripheral: \(name) with RSSI: \(RSSI.intValue)")
        
        // Filter only the devices of interest, including the new "ESP32_BEACON"
        guard ["ESP32-BEACON-1", "ESP32-BEACON-2", "ESP32-BEACON-3", "ESP32-BEACON-4", "ESP32-BEACON-5", "ESP32_BEACON"].contains(name) else {
            logDebug("Ignored peripheral: \(name) (Not in our list)")
            return
        }
        
        if let index = discoveredPeripherals.firstIndex(where: { $0.identifier == identifier }) {
            // Update the RSSI value for an existing device
            discoveredPeripherals[index].updateRSSI(RSSI.intValue)
            logDebug("Updated RSSI for: \(name), new RSSI: \(discoveredPeripherals[index].rssi)")
        } else {
            // Add new device
            let peripheralInfo = PeripheralInfo(identifier: identifier, name: name, rssi: RSSI.intValue)
            discoveredPeripherals.append(peripheralInfo)
            logDebug("Added new peripheral: \(name) with initial RSSI: \(RSSI.intValue)")
        }
        
        // Trigger room update after processing peripherals
        updateDetectedRoom()
    }

    // Function to determine the room based on the two strongest RSSI values
    func updateDetectedRoom() {
        // Sort peripherals by RSSI (strongest first)
        let sortedPeripherals = discoveredPeripherals.sorted { $0.rssi > $1.rssi }
        
        // Log detected peripherals and their RSSI
        logDebug("Current detected peripherals and their RSSI values:")
        for peripheral in sortedPeripherals {
            logDebug("Peripheral: \(peripheral.name), RSSI: \(peripheral.rssi)")
        }
        
        // We need at least two peripherals to determine the room
        guard sortedPeripherals.count >= 2 else {
            detectedRoom = lastDetectedRoom // Use the last detected room if fewer than 2 beacons
            logDebug("Less than 2 peripherals detected. Reverting to last known room: \(lastDetectedRoom)")
            return
        }
        
        // Get the names of the top two peripherals with the highest RSSI
        let topTwoPeripherals = sortedPeripherals.prefix(2)
        let firstBeacon = topTwoPeripherals[0].name
        let secondBeacon = topTwoPeripherals[1].name
        
        // Determine the room based on the two strongest signals
        let newRoom = determineRoom(firstBeacon: firstBeacon, secondBeacon: secondBeacon)
        
        // Update detected room and store last detected room
        if newRoom != "Undetermined room" {
            detectedRoom = newRoom
            lastDetectedRoom = newRoom // Store as last valid room
            logDebug("Room determined based on top beacons: \(firstBeacon), \(secondBeacon) -> Room: \(detectedRoom)")
        } else {
            // If undetermined, fall back to the last known room
            detectedRoom = lastDetectedRoom
            logDebug("Falling back to last known room: \(lastDetectedRoom)")
        }
    }

    // Map the two strongest beacons to specific rooms, including the new beacon
    private func determineRoom(firstBeacon: String, secondBeacon: String) -> String {
        switch (firstBeacon, secondBeacon) {
        case ("ESP32-BEACON-1", "ESP32-BEACON-2"), ("ESP32-BEACON-2", "ESP32-BEACON-1"):
            return "Room 405-712"
        case ("ESP32-BEACON-2", "ESP32-BEACON-3"), ("ESP32-BEACON-3", "ESP32-BEACON-2"):
            return "Room 405-722"
        case ("ESP32-BEACON-2", "ESP32_BEACON"), ("ESP32_BEACON", "ESP32-BEACON-2"):
            return "Room 405-722"
        case ("ESP32-BEACON-3", "ESP32_BEACON"), ("ESP32_BEACON", "ESP32-BEACON-3"):
            return "Room 405-722"
        case ("ESP32-BEACON-4", "ESP32_BEACON"), ("ESP32_BEACON", "ESP32-BEACON-4"):
            return "Room 405-722"
        case ("ESP32-BEACON-3", "ESP32-BEACON-4"), ("ESP32-BEACON-4", "ESP32-BEACON-3"):
            return "Room 405-722"
        case ("ESP32-BEACON-2", "ESP32-BEACON-4"), ("ESP32-BEACON-4", "ESP32-BEACON-2"):
            return "Room 405-722"
        case ("ESP32-BEACON-4", "ESP32-BEACON-5"), ("ESP32-BEACON-5", "ESP32-BEACON-4"):
            return "Room 405-736"
        default:
            return "Undetermined room"
        }
    }
    
    // Log function to store and print debug messages
    private func logDebug(_ message: String) {
        debugLogs.append(message)
        print(message) // Print to console for Xcode logs
    }
}
