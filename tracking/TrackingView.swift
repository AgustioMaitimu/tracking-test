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
	// Use @ObservedObject for a manager passed from a parent view
	@ObservedObject var locationManager: LocationManager
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
					
					ForEach(Array(coordinates.enumerated()), id: \.offset) { index, coord in
						if index == 0 {
							Marker("Start", systemImage: "flag.fill", coordinate: coord)
								.tint(.green)
						} else if index == coordinates.count - 1 {
							Marker("End", systemImage: "flag.checkered", coordinate: coord)
								.tint(.red)
						} else {
							Annotation("", coordinate: coord, anchor: .center) {
								ZStack {
									Circle().fill(Color.blue)
									Text("\(index)")
										.font(.system(size: 12, weight: .bold))
										.foregroundColor(.white)
								}
								.frame(width: 22, height: 22)
								.overlay(Circle().stroke(Color.white, lineWidth: 2))
							}
						}
					}
				}
			}
			.mapStyle(.standard)
			.ignoresSafeArea(edges: .bottom)
			.onChange(of: locationPoints.count) { _, _ in
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
					
					Button(action: toggleTracking) {
						Text(locationManager.isUpdatingLocation ? "Stop Tracking" : "Start Tracking")
							.font(.headline.bold())
							.padding()
							.frame(minWidth: 160)
							.background(locationManager.isUpdatingLocation ? Color.red : Color.green)
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
			// Reflect the persisted tracking state when the view appears
			if UserDefaults.standard.bool(forKey: "isTrackingEnabled") {
				locationManager.startLocationUpdate()
			}
		}
		.navigationTitle("Tracking")
	}
	
	private func toggleTracking() {
		if locationManager.isUpdatingLocation {
			// Set the flag to false so the app doesn't restart tracking on its own
			UserDefaults.standard.set(false, forKey: "isTrackingEnabled")
			locationManager.stopLocationUpdate()
		} else {
			// Set the flag to true to allow background relaunch to resume tracking
			UserDefaults.standard.set(true, forKey: "isTrackingEnabled")
			locationManager.startLocationUpdate()
		}
	}
	
	private func regionForCoordinates(_ coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion? {
		guard let first = coords.first else { return nil }
		var minLat = first.latitude, maxLat = first.latitude
		var minLon = first.longitude, maxLon = first.longitude
		for c in coords {
			minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
			minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
		}
		let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
		let span = MKCoordinateSpan(latitudeDelta: max((maxLat - minLat) * 1.5, 0.005),
									longitudeDelta: max((maxLon - minLon) * 1.5, 0.005))
		return MKCoordinateRegion(center: center, span: span)
	}
}

//#Preview {
//	TrackingView()
//}
