import SwiftUI

struct CalendarClockView: View {
    @State private var currentDate = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            // Date Title
            Text(currentDate.formatted(.dateTime.weekday(.wide).month().day().year()))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.top)

            // Digital Clock
            Text(currentDate.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .padding(.horizontal)

            // Mini Calendar View
            CalendarGrid(currentDate: currentDate)

            Spacer()

            // Footer
            Text("All times are based on your local timezone")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onReceive(timer) { input in
            withAnimation(.easeInOut(duration: 0.3)) {
                currentDate = input
            }
        }
    }
}

// MARK: - Calendar Grid View

struct CalendarGrid: View {
    var currentDate: Date

    private var calendar: Calendar { Calendar.current }
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }
        var dates: [Date] = []
        var date = monthInterval.start
        while date < monthInterval.end {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        return dates
    }

    private var startWeekdayOffset: Int {
        calendar.component(.weekday, from: daysInMonth.first ?? Date()) - calendar.firstWeekday
    }

    var body: some View {
        VStack {
            // Month and Year
            Text(currentDate.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
                .padding(.bottom, 5)

            // Days of the week header
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                }
            }

            // Grid of days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Empty spaces
                ForEach(0..<startWeekdayOffset, id: \.self) { _ in
                    Color.clear
                        .frame(height: 30)
                }

                // Days
                ForEach(daysInMonth, id: \.self) { date in
                    let day = calendar.component(.day, from: date)
                    let isToday = calendar.isDate(date, inSameDayAs: currentDate)

                    Text("\(day)")
                        .font(.caption)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(isToday ? Color.orange : Color.clear)
                                .animation(.spring(), value: isToday)
                        )
                        .foregroundColor(isToday ? .white : .primary)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground).opacity(0.8))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

#Preview {
    CalendarClockView()
}
