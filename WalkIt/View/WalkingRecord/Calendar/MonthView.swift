//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import CoreLocation

struct MonthView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    init(vm: WalkingRecordViewModel) { self.vm = vm }
    
    var walk: [WalkRecordEntity] = []
    var body: some View {
        VStack(spacing: 0) {
            calendarCard
                .padding(.bottom, 10)
            
            WalkItCountView(leftTitle: "평균 걸음", rightTitle: "누적 산책 시간", avgSteps: $vm.monthAvgSteps, walkTime: $vm.monthWalkTime)
                .padding(.bottom, 8)
            
            EmotionCardView(emotion: $vm.emotionMonth, count: $vm.emotionMonthCount, day: "이번 달에")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $vm.showingPicker) {
            YearMonthWheelPicker(monthAnchor: $vm.currentMonthAnchor) {
                vm.showingPicker = false
            }
            .presentationDetents([.height(280)])
        }
        .onChange(of: vm.currentMonthAnchor) {
            vm.setMothView()
            Task {
                await vm.getMissionCompletedMonthly()
            }
        }
    }
}

// MARK: - Sections
private extension MonthView {
    // MARK: Month
    var calendarCard: some View {
        VStack(spacing: 0) {
            CalendarHeader(currentMonth: $vm.currentMonthAnchor, showingPicker: $vm.showingPicker)
                .padding(.bottom, 10)
            
            MonthGrid(
                monthAnchor: vm.currentMonthAnchor,
                selected: $vm.selectedDate,
                stampedDays: vm.monthStampedDays,
                stampedMissionDays: vm.monthMissionStampedDays,
                onDaySelected: { day in
                    vm.currentDay = day
                    vm.getDayView(date: day)
                    vm.goNext(.dayView)
                }
            )
            .padding(.bottom, 4)
            
            HStack(spacing: 0) {
                Circle().fill(Color("CustomGreen2")).frame(width: 9, height: 9)
                    .padding(.trailing, 4)
                Text("산책")
                    .figmaText(fontSize: 12, weight: .regular, lineHeightPercent: 1.3)
                    .padding(.trailing, 12)
                Circle().fill(Color("CustomBlue6")).frame(width: 9, height: 9)
                    .padding(.trailing, 4)
                Text("미션")
                    .figmaText(fontSize: 12, weight: .regular, lineHeightPercent: 1.3)
            }
        }
        .padding(.bottom, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

private struct CalendarHeader: View {
    @Binding var currentMonth: Date
    @Binding var showingPicker: Bool
    let weekdays = ["일","월","화","수","목","금","토"]

    private var title: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 M월"
        return fmt.string(from: currentMonth)
    }
    
    var body: some View {
        HStack(spacing: 64) {
            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 9, height: 16)
                    .foregroundStyle(Color("CustomGray"))
            }
            
            Button {
                showingPicker = true
            } label: {
                Text(title)
                    .figmaText(fontSize: 18, weight: .medium)
                    .foregroundStyle(Color("CustomBlack"))
            }

            Button {
                currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 9, height: 16)
                    .foregroundStyle(Color("CustomGray"))
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
        
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { w in
                Text(w)
                    .figmaText(fontSize: 14, weight: .semibold)
                    .foregroundStyle(Color("CustomGray"))
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct MonthGrid: View {
    let monthAnchor: Date
    @Binding var selected: Date?
    let stampedDays: Set<Int>
    let stampedMissionDays: Set<Int>
    var onDaySelected: ((Date) -> Void)? = nil
    
    private var days: [Date] {
        let cal = Calendar.current
        guard let monthInterval = cal.dateInterval(of: .month, for: monthAnchor) else {
            return []
        }
        let firstWeekStart = cal.dateInterval(of: .weekOfMonth, for: monthInterval.start)?.start ?? monthInterval.start
        let lastWeekEnd = cal.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1))?.end ?? monthInterval.end
        
        var result: [Date] = []
        var cursor = firstWeekStart
        while cursor < lastWeekEnd {
            result.append(cursor)
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? cursor
            if cursor == result.last { break }
        }
        return result
    }
    
    private func isInCurrentMonth(_ date: Date) -> Bool {
        let cal = Calendar.current
        return cal.isDate(date, equalTo: monthAnchor, toGranularity: .month)
    }
    
    private func dayNumber(_ date: Date) -> Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            ForEach(days, id: \.self) { day in
                let inMonth = isInCurrentMonth(day)
                let number = dayNumber(day)
                let isSelected = selected.map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false
                let isWalkStamped = stampedDays.contains(number) && inMonth
                let isMissionStamped = stampedMissionDays.contains(number) && inMonth
                let textColor = inMonth ? Color("CustomBlack3") : Color("CustomLightGray5")
                VStack(spacing: 0) {
                    Text("\(number)")
                        .figmaText(fontSize: 14, weight: isSelected ? .semibold : .regular)
                        .foregroundStyle(isSelected ? Color("CustomBlue5") : textColor)
                        .frame(maxWidth: .infinity, maxHeight: 28)
                        .padding(.bottom, 8)
                    
                    HStack(spacing: 4) {
                        if isWalkStamped {
                            Circle().fill(Color("CustomGreen2")).frame(width: 7, height: 7)
                        }
                        if isMissionStamped {
                            Circle().fill(Color("CustomBlue6")).frame(width: 7, height: 7)
                        }
                    }
                    Spacer()
                }
                .frame(height: 61)
                .background {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(isSelected ? Color("CustomBlue5") : .clear, lineWidth: 1)
                        .background {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(isSelected ? Color(Color("CustomLightBlue")) : .clear)
                        }
                }
                .onTapGesture {
                    guard inMonth else { return }
                    selected = day
                    if(isWalkStamped) {
                        onDaySelected?(day)
                    }
                }
            }
        }
    }
}
