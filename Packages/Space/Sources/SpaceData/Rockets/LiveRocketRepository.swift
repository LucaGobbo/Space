//
//  LiveRocketRepository.swift
//  SpaceData
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceAPI
import SpaceDomain

public struct LiveRocketRepository: RocketRepository {
    // MARK: - Properties
    public static let spaceXManufacturer = "SpaceX"
    private var service: RocketService
    private var manufacturer: String

    // MARK: - init
    public init(
        service: RocketService,
        manufacturer: String = LiveRocketRepository.spaceXManufacturer
    ) {
        self.service = service
        self.manufacturer = manufacturer
    }

    // MARK: - API
    public func rockets(limit: Int, offset: Int) async throws -> RocketPage {
        let dto = try await service.rockets(limit: limit, offset: offset, manufacturer: manufacturer)
        return RocketPage(dto: dto)
    }

    public func rocket(id: Int) async throws -> Rocket {
        Rocket(dto: try await service.rocket(id: id))
    }
}
