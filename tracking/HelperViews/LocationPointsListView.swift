//
//  LocationPointsListView.swift
//  test-complete
//
//  Created by Agustio Maitimu on 06/10/25.
//

import SwiftUI
import CoreLocation

struct LocationPointsListView: View {
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        // newest first
        let coords = Array(locationManager.locations.reversed())
        List(Array(coords.enumerated()), id: \.offset) { idx, coord in
            HStack(spacing: 12) {
                Text("#\(idx + 1)")
                    .foregroundStyle(.secondary)
                Text("\(format(coord.latitude)), \(format(coord.longitude))")
                    .fontDesign(.monospaced)
                Spacer()
            }
        }
        .navigationTitle("Location Points")
    }

    private func format(_ value: CLLocationDegrees) -> String {
        String(format: "%.6f", value)
    }
}

#Preview {
    LocationPointsListView(locationManager: LocationManager())
}
