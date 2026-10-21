//
//  LiveLaunchRepository.swift
//  SpaceData
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation
import SpaceAPI
import SpaceDomain

/// Fetches launches from Launch Library 2 and maps them to domain models.
public struct LiveLaunchRepository: LaunchRepository {
    // MARK: - Properties
    /// Launch Library 2 id of SpaceX.
    public static let spaceXAgencyID = 121

    private var service: LaunchService
    private var agencyID: Int

    // MARK: - init

    public init(
        service: LaunchService,
        agencyID: Int = LiveLaunchRepository.spaceXAgencyID
    ) {
        self.service = service
        self.agencyID = agencyID
    }

    // MARK: - API
    public func launches(in range: ClosedRange<Date>?, limit: Int, offset: Int) async throws -> LaunchPage {
        let dto = try await service.launches(limit: limit, offset: offset, agencyID: agencyID, range: range)
        return LaunchPage(dto: dto)
    }
}
