//
//  RangePicker.swift
//  Space
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SwiftUI

struct RangePicker: View {

    // MARK: - Properties
    @Binding var dates: ClosedRange<Date>?
    @Environment(\.calendar) private var calendar
    @State var firstDate: Date = Date.now
    @State var secondDate: Date = Date.now.addingTimeInterval(3600 * 24)

    // MARK: - Body
    var body: some View {
        Form {
            Section {
                DatePicker(
                    LocalizedStringResource("Start date", bundle: #bundle),
                    selection: $firstDate,
                    in: ...secondDate,
                    displayedComponents: .date
                )
                DatePicker(
                    LocalizedStringResource("End date", bundle: #bundle),
                    selection: $secondDate,
                    in: firstDate...,
                    displayedComponents: .date
                )
            } footer: {
                Text("Select a range of dates to filter out launches", bundle: #bundle)
            }

            Section {
                ControlGroup {
                    ForEach(Preset.allCases) { preset in
                        Button(preset.title) { apply(preset) }
                    }
                }.controlSize(.small)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle(LocalizedStringResource("Dates", bundle: #bundle))
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbarRole(.editor)
        .task {
            guard let dates else {
                initializeDate()
                return
            }
            self.firstDate = dates.lowerBound
            self.secondDate = dates.upperBound
        }
        .toolbar {
            RangePickerToolbar(
                selectedRange: firstDate...secondDate,
                dates: $dates
            )
        }
    }

    // MARK: - Presets

    private enum Preset: CaseIterable, Identifiable {
        case thisMonth, lastMonth, thisYear, lastYear

        var id: Self { self }

        var title: LocalizedStringResource {
            switch self {
            case .thisMonth: LocalizedStringResource("This month", bundle: #bundle)
            case .lastMonth: LocalizedStringResource("Last month", bundle: #bundle)
            case .thisYear: LocalizedStringResource("This year", bundle: #bundle)
            case .lastYear: LocalizedStringResource("Last year", bundle: #bundle)
            }
        }

        var component: Calendar.Component {
            switch self {
            case .thisMonth, .lastMonth: .month
            case .thisYear, .lastYear: .year
            }
        }

        var offset: Int {
            switch self {
            case .thisMonth, .thisYear: 0
            case .lastMonth, .lastYear: -1
            }
        }
    }

    private func apply(_ preset: Preset, now: Date = .now) {
        guard
            let reference = calendar.date(byAdding: preset.component, value: preset.offset, to: now),
            let interval = calendar.dateInterval(of: preset.component, for: reference)
        else { return }
        firstDate = interval.start
        secondDate = calendar.startOfDay(for: interval.end.addingTimeInterval(-1))
    }

    // MARK: - API

    private func initializeDate(now: Date = .now) {
        firstDate =
            calendar.date(byAdding: .year, value: -2, to: now, wrappingComponents: true)
            .flatMap {
                calendar.startOfDay(for: $0)
            }
            ?? calendar.startOfDay(for: now)

        secondDate =
            calendar.date(byAdding: .year, value: 2, to: now, wrappingComponents: true)
            .flatMap { calendar.startOfDay(for: $0) }
            ?? calendar.startOfDay(for: now).addingTimeInterval(3600 * 24)
    }
}

// MARK: - Toolbar

private struct RangePickerToolbar: ToolbarContent {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.calendar) private var calendar
    var selectedRange: ClosedRange<Date>
    @Binding var dates: ClosedRange<Date>?

    // MARK: - Body
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(role: .destructive) {
                dates = nil
                dismiss()
            } label: {
                Label(LocalizedStringResource("Clear", bundle: #bundle), systemImage: "trash")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button(role: .confirm) {
                dates = selectedRange.inclusiveRange(calendar: calendar)
                dismiss()
            } label: {
                Label(LocalizedStringResource("Save", bundle: #bundle), systemImage: "checkmark")
            }
        }
    }
}

extension ClosedRange where Bound == Date {
    fileprivate func inclusiveRange(calendar: Calendar) -> ClosedRange<Date> {
        let start = calendar.startOfDay(for: lowerBound)
        let endDay = calendar.startOfDay(for: Swift.max(lowerBound, upperBound))
        let nextDay = calendar.date(byAdding: .day, value: 1, to: endDay) ?? endDay.addingTimeInterval(86_400)
        return start...nextDay.addingTimeInterval(-1)
    }
}

// MARK: - Previews
#Preview {
    @Previewable @State var dates: ClosedRange<Date>?
    NavigationStack {
        RangePicker(dates: $dates)
            #if os(iOS)
                .toolbar {

                    ToolbarItem(placement: .bottomBar) {
                        if let dates {
                            Text((dates.lowerBound..<dates.upperBound).formatted())
                        }
                    }
                }
            #endif
    }
}
