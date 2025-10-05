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

	// Human-readable authorization status for UI/debugging
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
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        self.isUpdatingLocation = true
    }

	func stopLocationUpdate() {
		locationManager.stopUpdatingLocation()
		locationManager.allowsBackgroundLocationUpdates = false
		self.isUpdatingLocation = false
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		
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
