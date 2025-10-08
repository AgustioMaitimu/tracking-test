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
	static let shared = LocationManager()
	
	@Published var isMonitoringSLC: Bool = false
	@Published var isUpdatingLocation: Bool = false
	@Published var isMonitoringGeofence: Bool = false
	@Published var authStatus: CLAuthorizationStatus = .notDetermined
	
	private let locationManager = CLLocationManager()
	var modelContext: ModelContext?
	
	private let geofenceRegionIdentifier = "user_geofence"
	
	private override init() {
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		locationManager.distanceFilter = 20
		locationManager.activityType = .automotiveNavigation
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.pausesLocationUpdatesAutomatically = false
		locationManager.showsBackgroundLocationIndicator = true
		self.authStatus = locationManager.authorizationStatus
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
	
	// --- Geofencing Methods ---
	
	func startGeofenceMonitoring() {
		guard authStatus == .authorizedAlways else {
			print("Cannot start geofence monitoring without 'Always' authorization.")
			return
		}
		
		guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
			print("Geofencing is not supported on this device.")
			return
		}
		
		print("Starting geofence monitoring.")
		isMonitoringGeofence = true
		locationManager.requestLocation() // Get a single location to set the first geofence
	}
	
	func stopGeofenceMonitoring() {
		print("Stopping geofence monitoring.")
		// We need a region to stop monitoring, even a dummy one with the correct identifier
		let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 100, identifier: geofenceRegionIdentifier)
		locationManager.stopMonitoring(for: region)
		isMonitoringGeofence = false
	}
	
	private func setupGeofence(around location: CLLocation) {
		// First, remove the old geofence to ensure we only have one active
		for region in locationManager.monitoredRegions {
			if region.identifier == geofenceRegionIdentifier {
				locationManager.stopMonitoring(for: region)
			}
		}
		
		// Now, create and start monitoring the new one
		let geofenceRegion = CLCircularRegion(center: location.coordinate,
											  radius: 100, // 100 meters radius
											  identifier: geofenceRegionIdentifier)
		geofenceRegion.notifyOnExit = true
		geofenceRegion.notifyOnEntry = false
		
		locationManager.startMonitoring(for: geofenceRegion)
		print("Created new geofence around \(location.coordinate.latitude), \(location.coordinate.longitude)")
	}
	
	// --- High-Frequency Update Methods ---
	
	func startLocationUpdate() {
		print("Starting high-frequency updates.")
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.showsBackgroundLocationIndicator = true
		locationManager.startUpdatingLocation()
		self.isUpdatingLocation = true
	}
	
	func stopLocationUpdate() {
		print("Stopping all location services.")
		locationManager.stopUpdatingLocation()
		stopGeofenceMonitoring()
		self.isUpdatingLocation = false
	}
	
	// --- CLLocationManagerDelegate Methods ---
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		
		// This is the initial location for setting up the first geofence
		if isMonitoringGeofence && !isUpdatingLocation {
			setupGeofence(around: location)
		}
		
		if isUpdatingLocation {
			print("Received location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
			let point = LocationPoint(latitude: location.coordinate.latitude,
									  longitude: location.coordinate.longitude,
									  timestamp: Date())
			modelContext?.insert(point)
			
			// --- THIS IS THE FIX ---
			// Explicitly save the context to ensure data is persisted when
			// the app is running in the background.
			do {
				try modelContext?.save()
				print("Successfully saved location point.")
			} catch {
				print("Failed to save location point: \(error.localizedDescription)")
			}
			// --- END FIX ---
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		print("Exited geofence region. Switching to high-frequency updates.")
		stopGeofenceMonitoring()
		startLocationUpdate()
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location manager error: \(error.localizedDescription)")
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		self.authStatus = manager.authorizationStatus
	}
	
	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("Geofence monitoring failed for region \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
	}
}
