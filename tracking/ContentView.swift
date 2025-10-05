//
//  ContentView.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI

struct ContentView: View {
	var locationManager = LocationManager()
	
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

#Preview {
    ContentView()
}
