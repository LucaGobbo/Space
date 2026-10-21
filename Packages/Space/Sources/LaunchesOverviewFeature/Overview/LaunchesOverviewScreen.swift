//
//  LaunchesOverviewScreen.swift
//  LaunchesOverviewFeature
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SpaceDomain
import SpacePaging
private import SpaceUI
import SwiftUI

public struct LaunchesOverviewScreen: View {

    // MARK: - Properties
    private var presentRocket: (Rocket.ID) -> Void
    @State private var viewModel: LaunchesOverviewViewModel
    @State private var isDateSelectorPresented = false
    @Environment(\.dimensions) private var dimensions

    // MARK: - init
    public init(
        launchRepository: LaunchRepository,
        presentRocket: @escaping (Rocket.ID) -> Void = { _ in }
    ) {
        self._viewModel = State(
            initialValue: LaunchesOverviewViewModel(
                launchRepository: launchRepository
            )
        )
        self.presentRocket = presentRocket
    }

    // MARK: - Body
    public var body: some View {
        LaunchesList(
            launches: viewModel.launches,
            isPaging: viewModel.paginator.isPaging,
            offset: viewModel.paginator.offset,
            totalCount: viewModel.paginator.totalCount,
            nextPage: viewModel.requestNextPage,
            presentRocket: presentRocket
        )
        .overlay {
            if viewModel.paginator.isInitial {
                ProgressView {
                    Text("Loading launches", bundle: #bundle)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            } else if viewModel.launches.isEmpty {
                RefreshView {
                    Label(LocalizedStringResource("No launches found", bundle: #bundle), systemImage: "paperplane")
                } description: {
                    Text("Retry?", bundle: #bundle)
                }
                .transition(.blurReplace)
            }
        }
        .animation(.default, value: viewModel.paginator.state.animationHash)
        .error(viewModel.paginator.error, dismiss: viewModel.dismissFailure)
        .task(
            id: TaskID(
                pageRequest: viewModel.pageRequest,
                dateFilter: viewModel.dateFilter
            )
        ) {
            await viewModel.fetch()
        }
        .refreshable {
            await viewModel.fetch(refresh: true)
        }
        .navigationTitle(LocalizedStringResource("Launches", bundle: #bundle))
        .toolbar {
            ToolbarItem {
                Button(role: viewModel.dateFilter == nil ? nil : .confirm) {
                    isDateSelectorPresented.toggle()
                } label: {
                    Label(LocalizedStringResource("Filter", bundle: #bundle), systemImage: "calendar")
                }
                .popover(isPresented: $isDateSelectorPresented) {
                    NavigationStack {
                        RangePicker(dates: $viewModel.dateFilter)
                    }
                    .frame(minWidth: 300, minHeight: 500)
                    .presentationCompactAdaptation(.popover)
                }
            }
        }
    }

    private struct TaskID: Equatable {
        var pageRequest: Int?
        var dateFilter: ClosedRange<Date>?
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        LaunchesOverviewScreen(launchRepository: MockLaunchRepository.delayed(for: .seconds(1)))
    }
}

#Preview("Paging") {

    NavigationStack {
        LaunchesOverviewScreen(launchRepository: MockLaunchRepository.paging)
    }
}

#Preview("Empty") {
    NavigationStack {
        LaunchesOverviewScreen(launchRepository: MockLaunchRepository.empty)
    }
}

#Preview {
    @Previewable @State var id = UUID()
    NavigationStack {
        LaunchesOverviewScreen(launchRepository: MockLaunchRepository.failing)
            .id(id)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        id = UUID()
                    } label: {
                        Image(systemName: "circle")
                    }

                }
            }
    }
}
