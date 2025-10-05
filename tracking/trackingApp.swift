//
//  trackingApp.swift
//  tracking
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI
import SwiftData

@main
struct trackingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
		.modelContainer(for: [LocationPoint.self, ActivityEvent.self])
    }
}
