//
//  TrackingView.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI
import CoreLocation
import MapKit
import SwiftData

struct TrackingView: View {
	@Environment(\.modelContext) private var modelContext
	@StateObject private var locationManager = LocationManager.shared
	@Query(sort: \LocationPoint.timestamp, order: .forward) private var locationPoints: [LocationPoint]
	
	@State private var cameraPosition: MapCameraPosition = .automatic
	
	private var coordinates: [CLLocationCoordinate2D] {
		locationPoints.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
	}
	
	var body: some View {
		ZStack {
			Map(position: $cameraPosition) {
				if !coordinates.isEmpty {
					MapPolyline(coordinates: coordinates)
						.stroke(.blue, lineWidth: 5)
					
					if let first = coordinates.first {
						Marker("Start", systemImage: "flag.fill", coordinate: first)
							.tint(.green)
					}
					if let last = coordinates.last {
						Marker("End", systemImage: "flag.checkered", coordinate: last)
							.tint(.red)
					}
				}
			}
			.mapStyle(.standard)
			.ignoresSafeArea(edges: .bottom)
			.onChange(of: locationPoints.count) {
				if let region = regionForCoordinates(coordinates) {
					withAnimation(.easeOut) { cameraPosition = .region(region) }
				}
			}
			
			VStack {
				Spacer()
				HStack {
					Button {
						if let region = regionForCoordinates(coordinates) {
							withAnimation(.easeOut) { cameraPosition = .region(region) }
						}
					} label: {
						Image(systemName: "scope")
							.font(.title2)
							.padding()
							.background(.thinMaterial)
							.foregroundColor(.primary)
							.clipShape(Circle())
							.shadow(radius: 5)
					}
					
					Spacer()
					
					let isTracking = locationManager.isMonitoringGeofence || locationManager.isUpdatingLocation
					Button(action: toggleTracking) {
						Text(isTracking ? "Stop Tracking" : "Start Tracking")
							.font(.headline.bold())
							.padding()
							.frame(minWidth: 160)
							.background(isTracking ? Color.red : Color.green)
							.foregroundColor(.white)
							.cornerRadius(15)
							.shadow(radius: 5)
					}
				}
				.padding()
			}
		}
		.onAppear {
			locationManager.modelContext = modelContext
			if UserDefaults.standard.bool(forKey: "isTrackingEnabled") {
				if !locationManager.isMonitoringGeofence && !locationManager.isUpdatingLocation {
					locationManager.startGeofenceMonitoring()
				}
			}
		}
		.navigationTitle("Tracking")
	}
	
	private func toggleTracking() {
		let isTracking = locationManager.isMonitoringGeofence || locationManager.isUpdatingLocation
		if isTracking {
			UserDefaults.standard.set(false, forKey: "isTrackingEnabled")
			locationManager.stopLocationUpdate()
		} else {
			UserDefaults.standard.set(true, forKey: "isTrackingEnabled")
			locationManager.startGeofenceMonitoring()
		}
	}
	
	private func regionForCoordinates(_ coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
		guard !coords.isEmpty else { return nil }
		var minLat = coords[0].latitude, maxLat = coords[0].latitude
		var minLon = coords[0].longitude, maxLon = coords[0].longitude
		for c in coords {
			minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
			minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
		}
		let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
		let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLon - minLon) * 1.4)
		return MKCoordinateRegion(center: center, span: span)
	}
}
