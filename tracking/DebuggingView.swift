//
//  DebuggingView.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI
import CoreLocation
import SwiftData

struct DebuggingView: View {
	@Environment(\.modelContext) private var modelContext
	@StateObject private var locationManager = LocationManager.shared
	@StateObject private var activityMonitor = ActivityMonitor.shared // Use shared instance
	@Query private var locationPoints: [LocationPoint]
	@Query private var activities: [ActivityEvent]
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .center, spacing: 12) {
				HStack(spacing: 16) {
					Text("Location: \(locationManager.authorizationStatusText)")
					Text("Motion: \(activityMonitor.authorizationStatusText)")
				}
				
				HStack {
					Text("GeoFence: \(locationManager.isMonitoringGeofence ? "On" : "Off")")
					Text("LocUpdt: \(locationManager.isUpdatingLocation ? "On" : "Off")")
					Text("ActMon: \(activityMonitor.isMonitoring ? "On" : "Off")")
				}
				
				HStack {
					Button("GeoFence On") { locationManager.startGeofenceMonitoring() }
					Button("GeoFence Off") { locationManager.stopGeofenceMonitoring() }
				}
				
				HStack {
					Button("LocUpdt On") { locationManager.startLocationUpdate() }
					Button("LocUpdt Off") { locationManager.stopLocationUpdate() }
				}
				
				HStack {
					Button("ActMon On") { activityMonitor.startUpdates() }
					Button("ActMon Off") { activityMonitor.stopUpdates() }
				}
				
				if let last = locationPoints.last {
					Text("Loc: \(last.latitude), \(last.longitude)")
				} else {
					Text("No Locs yet")
				}
				
				Text("Act: \(activityMonitor.currentStatus)")
				
				HStack {
					NavigationLink("Loc Points: \(locationPoints.count)") {
						LocationPointsListView()
					}
					Button("Clear Locs") {
						do {
							try modelContext.delete(model: LocationPoint.self)
							try modelContext.save() // Explicitly save the context
							print("Successfully deleted all location points.")
						} catch {
							print("Failed to delete location points: \(error.localizedDescription)")
						}
					}
				}
				
				HStack {
					NavigationLink("Activities: \(activities.count)") {
						ActivitiesListView()
					}
					Button("Clear Activities") {
						do {
							try modelContext.delete(model: ActivityEvent.self)
							try modelContext.save()
							print("Successfully deleted all activity events.")
						} catch {
							print("Failed to delete activity events: \(error.localizedDescription)")
						}
					}
				}
				
				Button("Always Permission") {
					locationManager.requestAlwaysAuthorization()
				}
				.disabled(locationManager.authStatus == .authorizedAlways)
			}
			.padding()
			.navigationTitle("Debugging")
		}
		.onAppear {
			activityMonitor.refreshAuthorizationStatus()
			locationManager.modelContext = modelContext
			activityMonitor.modelContext = modelContext
		}
	}
}
