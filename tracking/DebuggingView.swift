//
//  DebuggingView.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI
import CoreLocation

struct DebuggingView: View {
	@StateObject private var locationManager = LocationManager()
	@StateObject private var activityMonitor = ActivityMonitor()
	
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
				
				if let last = locationManager.locations.last {
					Text("Loc: \(last.latitude), \(last.longitude)")
				} else {
					Text("No Locs yet")
				}
				
				Text("Act: \(activityMonitor.currentStatus)")
				
				NavigationLink("Loc Points: \(locationManager.locations.count)") {
					LocationPointsListView(locationManager: locationManager)
				}
				
				NavigationLink("Activities: \(activityMonitor.activities.count)") {
					ActivitiesListView(activityMonitor: activityMonitor)
				}
				
				Button("Clear Locs") {
					locationManager.clearLocations()
				}

				Button("Clear Activities") {
					activityMonitor.clearActivities()
				}
				
				Button("Always Permission") {
					locationManager.requestAlwaysAuthorization()
				}
			}
			.padding()
			.navigationTitle("Debugging")
		}
		.onAppear {
			activityMonitor.refreshAuthorizationStatus()
		}
	}
}



#Preview {
	DebuggingView()
}
