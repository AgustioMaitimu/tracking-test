//
//  ContentView.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var locationManager = LocationManager.shared
	@StateObject private var activityMonitor = ActivityMonitor()
	
	var body: some View {
		TabView {
			TrackingView()
				.tabItem {
					Label("Tracking", systemImage: "map")
				}
			
			DebuggingView()
				.tabItem {
					Label("Debugging", systemImage: "command")
				}
		}
		.onAppear {
			locationManager.requestInitialAuthorization()
		}
	}
}
