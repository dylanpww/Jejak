//
//  CalendarView.swift
//  journal cam
//
//  Created by Dylan on 13/06/26.
//


import SwiftUI

struct CalendarView: View {
    let userId: String

    @State private var viewModel = JournalViewModel()
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ZStack{
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.08, blue: 0.18),
                        Color(red: 0.10, green: 0.16, blue: 0.32)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    monthHeader
                    
                    weekdayHeader
                    
                    calendarGrid
                    
                    Divider()
                        .padding(.top, 8)
                    
                    entriesForSelectedDate
                }
                .padding(.horizontal)
                .navigationTitle("Calendar")
                .task { await viewModel.loadEntries(userId: userId) }
            }
        }
    }
    private var monthHeader: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.top, 8)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let days = daysInMonth()

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days, id: \.self) { date in
                if let date {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 40)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let hasEntry = entries(on: date).isEmpty == false

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.accentColor : Color.clear)
                    )
                    .foregroundStyle(isSelected ? .white : .primary)

                Circle()
                    .fill(hasEntry ? Color.accentColor : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(height: 40)
        }
    }

    private var entriesForSelectedDate: some View {
        let dayEntries = entries(on: selectedDate)

        return Group {
            if dayEntries.isEmpty {
                ContentUnavailableView(
                    "No entries",
                    systemImage: "book.closed",
                    description: Text(selectedDate.formatted(date: .long, time: .omitted))
                )
                .frame(maxHeight: .infinity)
            } else {
                List(dayEntries) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry, userId: userId, onDeleted: {
                        Task { await viewModel.loadEntries(userId: userId) }
                    })) {
                        EntryRowView(entry: entry)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func entries(on date: Date) -> [JournalEntry] {
        viewModel.entries.filter {
            calendar.isDate($0.createdAt, inSameDayAs: date)
        }
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return [] }

        let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
        let leadingEmptyDays = firstWeekday - 1

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyDays)

        for dayOffset in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: monthInterval.start) {
                days.append(date)
            }
        }

        return days
    }

    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}
