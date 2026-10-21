//
//  Launch.swift
//  SpaceDomain
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation

public struct Launch: Sendable, Hashable, Identifiable {
    // MARK: - Properties
    public let id: String
    public var name: String
    public var date: Date?
    public var status: Status?
    public var launchSite: String?
    public var launchSiteCoordinate: Coordinate?
    public var imageURL: URL?
    public var missionDescription: String?
    public var watchURLs: [URL]
    public var rocket: RocketConfiguration?

    // MARK: - init
    public init(
        id: String,
        name: String,
        date: Date?,
        status: Status?,
        launchSite: String?,
        launchSiteCoordinate: Coordinate? = nil,
        imageURL: URL?,
        missionDescription: String?,
        watchURLs: [URL],
        rocket: RocketConfiguration?
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.status = status
        self.launchSite = launchSite
        self.launchSiteCoordinate = launchSiteCoordinate
        self.imageURL = imageURL
        self.missionDescription = missionDescription
        self.watchURLs = watchURLs
        self.rocket = rocket
    }

    public struct Coordinate: Sendable, Hashable {
        public var latitude: Double
        public var longitude: Double

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    public struct Status: Sendable, Hashable {
        public var name: String
        public var abbreviation: String

        public init(name: String, abbreviation: String) {
            self.name = name
            self.abbreviation = abbreviation
        }
    }

    public struct RocketConfiguration: Sendable, Hashable {
        public let id: Int
        public var name: String
        public var fullName: String?
        public var variant: String?

        public init(id: Int, name: String, fullName: String?, variant: String?) {
            self.id = id
            self.name = name
            self.fullName = fullName
            self.variant = variant
        }
    }
}
