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
	
	// The central manager that will handle bluetooth interactions
	private var centralManager: CBCentralManager!
	
	// A unique restoration key to allow the system to relaunch the app for bluetooth events
	private let restorationId = "my-bluetooth-restoration-id"
	
	override init() {
		super.init()
		// Initialize the CBCentralManager with the restoration identifier
		let options = [CBCentralManagerOptionRestoreIdentifierKey: restorationId]
		centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
		self.authorizationStatus = centralManager.authorization
	}
	
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
		
		switch central.state {
		case .poweredOn:
			print("Bluetooth is Powered On.")
			startScanning()
		case .poweredOff:
			print("Bluetooth is Powered Off.")
			stopScanning()
		case .unsupported:
			print("Bluetooth is not supported on this device.")
		case .unauthorized:
			print("The app is not authorized to use Bluetooth.")
		case .resetting:
			print("Bluetooth is resetting.")
		case .unknown:
			print("Bluetooth state is unknown.")
		@unknown default:
			print("A new, unknown Bluetooth state has been detected.")
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		// Add the peripheral to our list if it's not already there to avoid duplicates
		if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
			discoveredPeripherals.append(peripheral)
		}
		
		// ⚠️ IMPORTANT: Replace "Your-Earbuds-Name" with the actual name of your device.
		if let peripheralName = peripheral.name, peripheralName.contains("TOZO AeroSound3") {
			stopScanning() // Stop scanning once you've found your device
			connect(to: peripheral)
		}
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		print("✅ Successfully connected to: \(peripheral.name ?? "Unknown Device")")
	}
	
	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		print("❌ Failed to connect to \(peripheral.name ?? "Unknown Device"). Error: \(error?.localizedDescription ?? "No error info")")
		startScanning() // Restart scanning if the connection fails
	}
	
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		if let error = error {
			print("🔌 Disconnected from \(peripheral.name ?? "Unknown Device") with error: \(error.localizedDescription)")
		} else {
			print("🔌 Disconnected from \(peripheral.name ?? "Unknown Device")")
		}
		startScanning() // Restart scanning to find the device again
	}
	
	func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
		print("Central Manager will restore state.")
		if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
			print("Restoring peripherals: \(peripherals.map { $0.name ?? "N/A" })")
			self.discoveredPeripherals = peripherals
		}
	}
}
