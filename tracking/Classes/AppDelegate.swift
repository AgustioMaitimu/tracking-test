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
	
	// A static container to ensure the AppDelegate and the main app use the same database
	static var container: ModelContainer?
	lazy var bluetoothManager = BluetoothManager() // <-- Add this
	lazy var activityMonitor = ActivityMonitor()
	
	// A lazy-loaded instance of your existing LocationManager
	lazy var locationManager: LocationManager = {
		let manager = LocationManager()
		if let container = AppDelegate.container {
			manager.modelContext = ModelContext(container)
		}
		return manager
	}()
	
	//	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
	//
	//		if launchOptions?[.location] != nil {
	//			print("App re-launched by a location event.")
	//
	//			// Check if the user had tracking enabled before termination
	//			if UserDefaults.standard.bool(forKey: "isTrackingEnabled") {
	//				print("Tracking was enabled. Switching to high-frequency updates.")
	//				// This is the key step: switch from SLC to standard updates
	//				locationManager.switchToHighFrequencyUpdates()
	//			}
	//		}
	//		return true
	//	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		
		print("App finished launching.")
		
		// Start scanning as soon as the app is ready
		bluetoothManager.startScanning()
		
		if launchOptions?[.bluetoothPeripherals] != nil {
			print("App re-launched by Bluetooth Central event.")
		}
		
		return true
	}
}
