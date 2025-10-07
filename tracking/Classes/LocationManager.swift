//
//  LocationManager.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import Foundation
import CoreLocation
import Combine
import SwiftData

@MainActor
class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
	@Published var isMonitoringSLC: Bool = false
	@Published var isUpdatingLocation: Bool = false
	@Published var authStatus: CLAuthorizationStatus = .notDetermined
	
	private let locationManager = CLLocationManager()
	
	var modelContext: ModelContext?
	
	override init() {
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		locationManager.distanceFilter = 20
		 locationManager.activityType = .automotiveNavigation
		
		if #available(iOS 14.0, *) {
			self.authStatus = locationManager.authorizationStatus
		} else {
			self.authStatus = type(of: locationManager).authorizationStatus()
		}
	}
	
	var authorizationStatusText: String {
		switch authStatus {
		case .authorizedAlways:
			return "Always"
		case .authorizedWhenInUse:
			return "WhenInUse"
		case .denied:
			return "Denied"
		case .restricted:
			return "Restricted"
		case .notDetermined:
			return "NotDetermined"
		@unknown default:
			return "Unknown"
		}
	}
	
	func requestInitialAuthorization() {
		locationManager.requestWhenInUseAuthorization()
	}
	
	func requestAlwaysAuthorization() {
		locationManager.requestAlwaysAuthorization()
	}
	
	func startSLC() {
		if CLLocationManager.significantLocationChangeMonitoringAvailable() {
			locationManager.startMonitoringSignificantLocationChanges()
			self.isMonitoringSLC = true
		} else {
			self.isMonitoringSLC = false
			print("Significant location monitoring is not available on this device.")
		}
	}
	
	func stopSLC() {
		locationManager.stopMonitoringSignificantLocationChanges()
		self.isMonitoringSLC = false
	}
	
	func startLocationUpdate() {
		print("Starting high-frequency updates AND significant location change monitoring.")
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.startUpdatingLocation()
		self.isUpdatingLocation = true
		
		// Also start SLC to enable relaunch from a terminated state
		if CLLocationManager.significantLocationChangeMonitoringAvailable() {
			locationManager.startMonitoringSignificantLocationChanges()
			self.isMonitoringSLC = true
		}
	}
	
	func stopLocationUpdate() {
		print("Stopping all location services.")
		locationManager.stopUpdatingLocation()
		locationManager.stopMonitoringSignificantLocationChanges()
		locationManager.allowsBackgroundLocationUpdates = false
		self.isUpdatingLocation = false
		self.isMonitoringSLC = false
	}
	
	/// Called by the AppDelegate when the app is relaunched in the background.
	func switchToHighFrequencyUpdates() {
		print("Switching from SLC to high-frequency updates.")
		// Stop SLC to avoid redundant updates if desired, though it's often fine to leave running
		// locationManager.stopMonitoringSignificantLocationChanges() // Optional: depends on desired battery/accuracy trade-off
		
		// Start the high-accuracy updates
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.startUpdatingLocation()
		self.isUpdatingLocation = true
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		
		print("Received location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
		let newLocationPoint = LocationPoint(latitude: location.coordinate.latitude,
											 longitude: location.coordinate.longitude,
											 timestamp: Date())
		modelContext?.insert(newLocationPoint)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location manager error: \(error.localizedDescription)")
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if #available(iOS 14.0, *) {
			self.authStatus = manager.authorizationStatus
		} else {
			self.authStatus = type(of: manager).authorizationStatus()
		}
	}
}
