//
//  Models.swift
//  tracking
//
//  Created by Agustio Maitimu on 06/10/25.
//

import Foundation
import SwiftData
import CoreLocation

@Model
class LocationPoint {
	var latitude: CLLocationDegrees
	var longitude: CLLocationDegrees
	var timestamp: Date
	
	init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, timestamp: Date) {
		self.latitude = latitude
		self.longitude = longitude
		self.timestamp = timestamp
	}
}

@Model
class ActivityEvent {
	@Attribute(.unique) var id: UUID
	var status: String
	var timestamp: Date
	
	init(id: UUID = UUID(), status: String, timestamp: Date) {
		self.id = id
		self.status = status
		self.timestamp = timestamp
	}
}
