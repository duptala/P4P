# P4P - Asset Tracking Prototype
**Final Year Research Project #136**

This repository contains the code for **P4P**, a prototype **Asset Tracking System** using **Bluetooth Low Energy (BLE)** modules. This system is part of a final-year undergraduate research project focused on evaluating the feasibility of BLE for asset localization in a university setting.

## Project Overview
This application tracks asset locations by scanning BLE beacons placed at various points within a building. By analyzing the signal strength (RSSI) of nearby BLE beacons, the app determines the asset’s room location based on the strongest signal combinations. This prototype highlights BLE's utility for room-level asset tracking in controlled environments.

### Key Features
- **Real-time BLE-based location detection**: Identifies the room based on the strongest two BLE signals.
- **QR Code Scanning**: Allows users to scan a QR code associated with an asset, view its details, and update its location.
- **Manual Room Update**: Users can move assets between rooms, updating the room location based on detected BLE signals.
- **Admin Dashboard**: Display all tracked assets with filtering and search capabilities.

## Requirements
- **iOS**: Version 16.0 or later
- **Xcode**: Version 12 or later
- **CoreBluetooth Framework**: Used for BLE scanning and peripheral management.
- **CodeScanner Library**: For QR code scanning functionality. Install using Swift Package Manager.

### External Services
- **Firebase**: Used for storing and retrieving asset data. While you won’t have access to the project’s Firebase instance, below is the database schema for reference.

## Firebase Database Schema
This application uses Firebase Firestore with the following structure:

- **Collection: `assets`**
  - **Document ID**: Unique ID for each asset.
  - **Fields**:
    - `name` (String): Name of the asset.
    - `code` (String): QR code value associated with the asset.
    - `level` (String): Floor level where the asset is located.
    - `room` (String): Room number where the asset is located.
    - `lastUpdatedAt` (Timestamp): The last time the asset’s location was updated.
    - `lastUpdatedByName` (String): Name of the person who last updated the asset.
    - `lastUpdatedByUPI` (String): UPI of the person who last updated the asset.
    - `imageUrl` (String): URL for the asset’s image.

You can replicate this schema if you set up your own Firebase project for testing or development purposes.

## Repository Structure
- **`HomeView.swift`**: Main view where users can see and filter assets, access the BLE-detected room feature, and scan QR codes.
- **`AssetDetailView.swift`**: Displays details of a specific asset after scanning its QR code. Users can view and update the asset’s location.
- **`BLEManager.swift`**: Manages BLE scanning, beacon detection, and room determination logic. Uses `CoreBluetooth` to interact with BLE peripherals.
- **`Asset.swift`**: Model struct representing an asset, including fields for name, level, room, and more.
- **`QRScannerView.swift`**: Handles QR code scanning, allowing users to scan assets and view details.

## Setup and Installation
1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/duptala/P4P.git
 2. Open the project in Xcode: `cd P4P` `open P4P.xcodeproj`
   
4. Install Dependencies
5. Configure Firebase

## Usage
### Start BLE Scanning
Open the app, and it will automatically start scanning for BLE beacons to detect the room based on the two strongest signals. The detected room displays on the home screen.

### Manage Assets
- Use the search bar to filter assets by name.
- Tap "Scan to Move" to open the QR scanner, scan an asset’s QR code, and navigate to the asset detail page where you can view and move the asset.

### Move and Update Location
On the asset detail page, press "Move" to begin moving the asset. The BLE-detected room will update as you move to a new location. Press "Finish Moving" to save the new room information in Firebase.

## Notes
- **UWB Compatibility**: This prototype currently does not support UWB, though the research explored its feasibility. The app focuses on BLE only.
- **RSSI Accuracy**: BLE RSSI signals can be unstable due to environmental factors. This system averages RSSI values for smoother readings.

## Future Improvements
- **UWB Integration**: Incorporate UWB for enhanced location accuracy in future versions.
- **Advanced Filtering**: Implement Kalman filters or other methods to improve RSSI signal stability.
- **Expanded Room Coverage**: Add more beacons for additional rooms and improve room-mapping logic.

## Contact
For any questions, improvements, or bug reports, please reach out to us:

- Devesh: [ddup656@aucklanduni.ac.nz](mailto:ddup656@aucklanduni.ac.nz)  
- Youngmin Kim: [ykim583@aucklanduni.ac.nz](mailto:ykim583@aucklanduni.ac.nz)

