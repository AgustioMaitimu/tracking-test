//
//  AppDelegate.swift
//  tracking
//
//  Created by Agustio Maitimu on 06/10/25.
//

import UIKit
import SwiftUI
import CoreLocation
import SwiftData

class AppDelegate: UIResponder, UIApplicationDelegate {
//	static var container: ModelContainer?
//	
//	func application(_ application: UIApplication,
//					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//		
//		if launchOptions?[.location] != nil {
//			print("App re-launched by a location event.")
//			if UserDefaults.standard.bool(forKey: "isTrackingEnabled") {
//				let locationManager = LocationManager.shared
//				if let container = AppDelegate.container {
//					locationManager.modelContext = ModelContext(container)
//				}
//				locationManager.startLocationUpdate()
//			}
//		}
//		return true
//	}
	
	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		if launchOptions?[.location] != nil {
			print("App re-launched by a location event.")
			if UserDefaults.standard.bool(forKey: "isTrackingEnabled") {
				
				guard let container = try? ModelContainer(for: LocationPoint.self, ActivityEvent.self) else {
					fatalError("Failed to create ModelContainer for background launch.")
				}
				
				let modelContext = ModelContext(container)
				
				let locationManager = LocationManager.shared
				locationManager.modelContext = modelContext
				locationManager.startLocationUpdate()
			}
		}
		return true
	}
}
