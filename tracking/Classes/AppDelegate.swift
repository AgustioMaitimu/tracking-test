//
//  AppDelegate.swift
//  tracking
//
//  Created by Agustio Maitimu on 06/10/25.
//

import UIKit
import SwiftUI
import CoreLocation
import SwiftData

class AppDelegate: UIResponder, UIApplicationDelegate {
	
	static var container: ModelContainer?
	
	// Create the single, shared instances here
	lazy var locationManager = LocationManager()
	lazy var bluetoothManager = BluetoothManager(locationManager: self.locationManager) // <-- Inject the locationManager
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		
		print("App finished launching.")
		
		// Start scanning as soon as the app is ready
		bluetoothManager.startScanning()
		
		if launchOptions?[.bluetoothPeripherals] != nil {
			print("App re-launched by Bluetooth Central event.")
		}
		
		if launchOptions?[.location] != nil {
			print("App re-launched by a location event.")
			
			// Check if the user had tracking enabled before termination
			if UserDefaults.standard.bool(forKey: "isTrackingEnabled") {
				print("Tracking was enabled. Switching to high-frequency updates.")
				locationManager.switchToHighFrequencyUpdates()
			}
		}
		
		return true
	}
}
