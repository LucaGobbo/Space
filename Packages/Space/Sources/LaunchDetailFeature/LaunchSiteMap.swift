//
//  LaunchSiteMap.swift
//  Space
//
//  Created by Luca Gobbo on 18/10/2026.
//

private import MapKit
import SpaceDomain
import SpaceUI
import SwiftUI

struct LaunchSiteMap: View {
    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    var name: String
    var coordinate: Launch.Coordinate

    private var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    // MARK: - Body
    var body: some View {
        Map(
            initialPosition: .region(
                MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                )
            )
        ) {
            Marker(name, coordinate: location)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: dimensions.spaceM))
        .allowsHitTesting(false)
    }
}

// MARK: - Previews
#Preview {
    if let launch = Launch.samples.first,
        let coordinate = launch.launchSiteCoordinate
    {
        LaunchSiteMap(
            name: launch.launchSite ?? "none",
            coordinate: coordinate
        )
    }
}
