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
	@StateObject private var locationManager = LocationManager()
	@StateObject private var activityMonitor = ActivityMonitor()
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
					Text("SLC: \(locationManager.isMonitoringSLC ? "On" : "Off")")
					Text("LocUpdt: \(locationManager.isUpdatingLocation ? "On" : "Off")")
					Text("ActMon: \(activityMonitor.isMonitoring ? "On" : "Off")")
				}
				
				HStack {
					Button("SLC On") {
						locationManager.startSLC()
					}
					
					Button("SLC Off") {
						locationManager.stopSLC()
					}
				}
				
				HStack {
					Button("LocUpdt On") {
						locationManager.startLocationUpdate()
					}
					
					Button("LocUpdt Off") {
						locationManager.stopLocationUpdate()
					}
				}
				
				HStack {
					Button("ActMon On") {
						activityMonitor.startUpdates()
					}
					
					Button("ActMon Off") {
						activityMonitor.stopUpdates()
					}
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
						for point in locationPoints {
							modelContext.delete(point)
						}
					}
				}
				
				HStack {
					NavigationLink("Activities: \(activities.count)") {
						ActivitiesListView()
					}
					
					Button("Clear Activities") {
						for activity in activities {
							modelContext.delete(activity)
						}
					}
				}
				
				Button("Always Permission") {
					locationManager.requestAlwaysAuthorization()
				}
				.disabled(locationManager.authorizationStatusText == "Always" ? true : false)
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



#Preview {
	DebuggingView()
}
