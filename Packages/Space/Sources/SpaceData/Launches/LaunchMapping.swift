//
//  LaunchMapping.swift
//  SpaceData
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SpaceAPI
import SpaceDomain

extension Launch {
    init(dto: LaunchesResponseDTO.Launch) {
        self.init(
            id: dto.id,
            name: dto.name,
            date: dto.net,
            status: dto.status.map { Status(name: $0.name, abbreviation: $0.abbrev) },
            launchSite: dto.pad?.location?.name,
            launchSiteCoordinate: dto.pad.flatMap(Coordinate.init(pad:)),
            imageURL: dto.image?.imageUrl,
            missionDescription: dto.mission?.description,
            watchURLs: dto.mission?.vidUrls.map(\.url) ?? [],
            rocket: dto.rocket.map {
                RocketConfiguration(
                    id: $0.configuration.id,
                    name: $0.configuration.name,
                    fullName: $0.configuration.fullName,
                    variant: $0.configuration.variant
                )
            }
        )
    }
}

extension LaunchPage {
    init(dto: LaunchesResponseDTO) {
        self.init(
            launches: dto.results.map(Launch.init(dto:)),
            totalCount: dto.count,
            isLastPage: dto.next == nil
        )
    }
}

extension Launch.Coordinate {
    init?(pad: LaunchesResponseDTO.Pad) {
        guard let latitude = pad.latitude, let longitude = pad.longitude else { return nil }
        self.init(latitude: latitude, longitude: longitude)
    }
}
