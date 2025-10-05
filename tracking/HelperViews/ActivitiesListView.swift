//
//  ActivitiesListView.swift
//  tracking
//
//  Created by Codex on 06/10/25.
//

import SwiftUI

struct ActivitiesListView: View {
    @ObservedObject var activityMonitor: ActivityMonitor

    var body: some View {
        // newest first
        let items = Array(activityMonitor.activities.reversed())
        List(Array(items.enumerated()), id: \.element.id) { idx, event in
            HStack(spacing: 12) {
                Text("#\(idx + 1)")
                    .foregroundStyle(.secondary)
                Text(format(date: event.timestamp))
                    .fontDesign(.monospaced)
                Text(event.status)
                Spacer()
            }
        }
        .navigationTitle("Activities")
    }

    private func format(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: date)
    }
}

#Preview {
    ActivitiesListView(activityMonitor: ActivityMonitor())
}
