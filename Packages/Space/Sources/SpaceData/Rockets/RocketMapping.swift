//
//  RocketMapping.swift
//  SpaceData
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceAPI
import SpaceDomain

extension Rocket {
    init(dto: RocketsResponseDTO.Rocket) {
        self.init(
            id: dto.id,
            name: dto.name,
            fullName: dto.fullName,
            variant: dto.variant,
            isActive: dto.active ?? false,
            imageURL: dto.image?.imageUrl,
            successfulLaunches: dto.successfulLaunches,
            failedLaunches: dto.failedLaunches,
            description: dto.description,
            family: dto.families?.last?.name,
            isReusable: dto.reusable,
            stageCount: dto.maxStage
        )
    }
}

extension RocketPage {
    init(dto: RocketsResponseDTO) {
        self.init(
            rockets: dto.results.map(Rocket.init(dto:)),
            totalCount: dto.count,
            isLastPage: dto.next == nil
        )
    }
}
