//
//  ContentView.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI

struct ContentView: View {
	// Create a single instance of each manager here
	@StateObject private var locationManager = LocationManager()
	@StateObject private var activityMonitor = ActivityMonitor()
	
	var body: some View {
		TabView {
			// Pass the same instances into your child views
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

#Preview {
	ContentView()
}
