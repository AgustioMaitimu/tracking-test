//
//  ContentView.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI

struct ContentView: View {
	// Use @ObservedObject for managers passed from a parent
	@ObservedObject var locationManager: LocationManager
	@StateObject private var activityMonitor = ActivityMonitor()
	
	var body: some View {
		TabView {
			TrackingView(locationManager: locationManager)
				.tabItem {
					Label("Tracking", systemImage: "map")
				}
			
			DebuggingView(locationManager: locationManager, activityMonitor: activityMonitor)
				.tabItem {
					Label("Debugging", systemImage: "command")
				}
		}
		.onAppear {
			locationManager.requestInitialAuthorization()
		}
	}
}
