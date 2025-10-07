//
//  BluetoothManager.swift
//  tracking
//
//  Created by Agustio Maitimu on 07/10/25.
//

import Foundation
import CoreBluetooth
import Combine

@MainActor
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
	@Published var authorizationStatus: CBManagerAuthorization = .notDetermined
	@Published var isScanning = false
	@Published var discoveredPeripherals: [CBPeripheral] = []
	
	private var centralManager: CBCentralManager!
	private let restorationId = "my-bluetooth-restoration-id"
	
	// Use the locationManager that is passed in
	private var locationManager: LocationManager
	
	// Modified initializer to accept a LocationManager
	init(locationManager: LocationManager) {
		self.locationManager = locationManager
		super.init()
		let options = [CBCentralManagerOptionRestoreIdentifierKey: restorationId]
		centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
		self.authorizationStatus = centralManager.authorization
	}
	
	// ... (rest of your BluetoothManager code is the same)
	
	// MARK: - Public Methods
	
	func startScanning() {
		guard centralManager.state == .poweredOn else {
			print("Bluetooth is not powered on.")
			return
		}
		
		print("Starting to scan for peripherals...")
		centralManager.scanForPeripherals(withServices: nil, options: nil)
		isScanning = true
	}
	
	func stopScanning() {
		guard centralManager.isScanning else { return }
		print("Stopping scan.")
		centralManager.stopScan()
		isScanning = false
	}
	
	func connect(to peripheral: CBPeripheral) {
		print("Attempting to connect to peripheral: \(peripheral.name ?? "Unknown Device")")
		centralManager.connect(peripheral, options: nil)
	}
	
	// MARK: - CBCentralManagerDelegate Methods
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		self.authorizationStatus = central.authorization
		
		if central.state == .poweredOn {
			print("Bluetooth is Powered On.")
			startScanning()
		} else {
			print("Bluetooth is Powered Off.")
			stopScanning()
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
			discoveredPeripherals.append(peripheral)
		}
		
		// ⚠️ IMPORTANT: Make sure this name matches your device.
		if let peripheralName = peripheral.name, peripheralName.contains("TOZO AeroSound3") {
			stopScanning()
			connect(to: peripheral)
		}
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		print("✅ Successfully connected to: \(peripheral.name ?? "Unknown Device")")
		print("▶️ Starting high-frequency location tracking.")
		locationManager.startLocationUpdate()
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		print("❌ Failed to connect to \(peripheral.name ?? "Unknown Device"). Error: \(error?.localizedDescription ?? "No error info")")
		startScanning()
	}
	
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		print("🔌 Disconnected from \(peripheral.name ?? "Unknown Device")")
		print("⏹️ Stopping high-frequency location tracking.")
		locationManager.stopLocationUpdate()
		startScanning() // Restart scanning to find the device again
	}
	
	func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
		print("Central Manager will restore state.")
		if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
			self.discoveredPeripherals = peripherals
		}
	}
}
