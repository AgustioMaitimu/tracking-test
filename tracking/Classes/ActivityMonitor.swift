//
//  ActivityMonitor.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import Foundation
import CoreMotion
import Combine
import SwiftData

class ActivityMonitor: NSObject, ObservableObject {
	private let activityManager = CMMotionActivityManager()
	
	@Published var currentStatus: String = "Unknown"
	@Published var authStatus: CMAuthorizationStatus = CMMotionActivityManager.authorizationStatus()
	@Published var isMonitoring: Bool = false
	
	var modelContext: ModelContext?
	
	var authorizationStatusText: String {
		switch authStatus {
		case .authorized:
			return "Authorized"
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
	
	func startUpdates() {
		guard CMMotionActivityManager.isActivityAvailable() else {
			currentStatus = "Unavailable"
			return
		}
		
		authStatus = CMMotionActivityManager.authorizationStatus()
		if authStatus == .denied || authStatus == .restricted {
			currentStatus = "NotAuthorized"
			return
		}
		
		isMonitoring = true
		activityManager.startActivityUpdates(to: .main) { [weak self] activity in
			guard let self else { return }
			guard let a = activity else { return }
			self.authStatus = CMMotionActivityManager.authorizationStatus()
			
			if a.automotive {
				self.currentStatus = "Automotive"
			} else if a.cycling {
				self.currentStatus = "Cycling"
			} else if a.running {
				self.currentStatus = "Running"
			} else if a.walking {
				self.currentStatus = "Walking"
			} else if a.stationary {
				self.currentStatus = "Stationary"
			} else {
				self.currentStatus = "Unknown"
			}
			
			let event = ActivityEvent(status: self.currentStatus, timestamp: a.startDate)
			self.modelContext?.insert(event)
		}
	}
	
	func stopUpdates() {
		activityManager.stopActivityUpdates()
		isMonitoring = false
	}
	
	func refreshAuthorizationStatus() {
		authStatus = CMMotionActivityManager.authorizationStatus()
	}
	
	deinit {
		activityManager.stopActivityUpdates()
	}
}
