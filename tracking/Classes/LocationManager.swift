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
	@Published var authStatus: CLAuthorizationStatus = .notDetermined
	
	private let locationManager = CLLocationManager()
	private var slcStartTime: Date?
	var modelContext: ModelContext?
	
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
	
	func startSLC() {
		if CLLocationManager.significantLocationChangeMonitoringAvailable() {
			print("Starting significant location change monitoring.")
			slcStartTime = Date() // Set debounce timer
			locationManager.startMonitoringSignificantLocationChanges()
			self.isMonitoringSLC = true
		} else {
			self.isMonitoringSLC = false
			print("Significant location monitoring is not available on this device.")
		}
	}
	
	func stopSLC() {
		print("Stopping significant location change monitoring.")
		locationManager.stopMonitoringSignificantLocationChanges()
		self.isMonitoringSLC = false
	}
	
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
		locationManager.stopMonitoringSignificantLocationChanges()
		self.isUpdatingLocation = false
		self.isMonitoringSLC = false
		slcStartTime = nil
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		
		if let slcStartTime = slcStartTime {
			if Date().timeIntervalSince(slcStartTime) < 2.0 {
				print("Ignoring immediate SLC trigger.")
				self.slcStartTime = nil
				return
			}
			self.slcStartTime = nil
		}
		
		//dis shit gets called from SLC trigger, hopefully, God help me please, im hanging on by a thread
		if isMonitoringSLC {
			print("SLC triggered, switching to high-frequency updates.")
			startLocationUpdate()
			stopSLC()
		}
		
		print("Received location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
		let point = LocationPoint(latitude: location.coordinate.latitude,
								  longitude: location.coordinate.longitude,
								  timestamp: Date())
		modelContext?.insert(point)
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location manager error: \(error.localizedDescription)")
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		self.authStatus = manager.authorizationStatus
	}
}
