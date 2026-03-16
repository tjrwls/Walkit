//
//  WalkingRecordView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI
import CoreLocation

struct WeekView: View {
    @ObservedObject var vm: WalkingRecordViewModel
    init(vm: WalkingRecordViewModel) { self.vm = vm }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                weeklyCard
                    .padding(.bottom, 8)
                
                WalkItCountView(leftTitle: "평균 걸음", rightTitle: "누적 산책 시간", avgSteps: $vm.weeklyAvgSteps, walkTime: $vm.weeklyWalkTime)
                    .padding(.bottom, 8)

                EmotionCardView(emotion: $vm.emotionWeek, count: $vm.emotionWeekCount,day: "이번 주")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $vm.showingPicker) {
            YearMonthWheelPicker(monthAnchor: $vm.currentWeekAnchor) {
                vm.showingPicker = false
            }
            .presentationDetents([.height(280)])
        }
        .onChange(of: vm.currentWeekAnchor) { vm.setWeekView() }
    }
}

// MARK: - Sections
private extension WeekView {
    // MARK: Week
    var weeklyCard: some View {
        VStack(spacing: 0) {
            WeekHeader(currentWeek: $vm.currentWeekAnchor, showingPicker: $vm.showingPicker)
                .padding(.bottom, 10)
            
            WeekStrip(weekAnchor: vm.currentWeekAnchor,
                      selected: $vm.selectedWeekDay,
                      stampedDays: vm.weeklystampedDays)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}


// MARK: - Week Components
private struct WeekHeader: View {
    @Binding var currentWeek: Date
    @Binding var showingPicker: Bool
    
    private var title: String {
        let cal = Calendar.current
        let weekOfMonth = monthMondayIndex(for: currentWeek, calendar: cal)
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 M월"
        let ym = fmt.string(from: currentWeek)
        let ordinal = ["","첫","둘","셋","넷","다섯"]
        let label = weekOfMonth >= 1 && weekOfMonth < ordinal.count ? "\(ordinal[weekOfMonth])째주" : "\(weekOfMonth)째주"
        return "\(ym) \(label)"
    }
    
    var body: some View {
        HStack(spacing: 64) {
            Button {
                currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
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
                currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 9, height: 16)
                    .foregroundStyle(Color("CustomGray"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 16)
        .padding(.bottom, 12)
        
        HStack(spacing: 12) {
            ForEach(daysOfWeekStrings(for: currentWeek), id: \.self) { day in
                Text(day)
                    .figmaText(fontSize: 14, weight: .regular)
                    .foregroundStyle(Color("CustomBlack3"))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 11)
    }
    
    func monthMondayIndex(for date: Date, calendar: Calendar = Calendar(identifier: .gregorian)) -> Int {
        var cal = calendar
        cal.firstWeekday = 2 // 월요일 시작

        // 1️⃣ 해당 달의 첫 날
        guard let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: date)) else {
            return 1
        }

        // 2️⃣ 해당 달의 첫 월요일 찾기
        let firstWeekday = cal.component(.weekday, from: startOfMonth)
        // 월요일까지 이동 (1=일요일, 2=월요일,...)
        let offsetToMonday = (9 - firstWeekday) % 7
        guard let firstMonday = cal.date(byAdding: .day, value: offsetToMonday, to: startOfMonth) else {
            return 1
        }

        // 3️⃣ 해당 날짜가 몇 번째 월요일 이후인지 계산
        let daysDiff = cal.dateComponents([.day], from: firstMonday, to: date).day ?? 0
        let index = (daysDiff / 7) + 1 // 첫 번째 월요일 = 1

        return max(index, 1)
    }

    func daysOfWeekStrings(for date: Date) -> [String] {
        let calendar = Calendar.current
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        
        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) else { return nil }
            return String(calendar.component(.day, from: day))
        }
    }
}

private struct WeekStrip: View {
    let weekAnchor: Date
    @Binding var selected: Date?
    let stampedDays: Set<Int>
    
    private var daysOfWeek: [Date] {
        let cal = Calendar.current
        guard let weekInterval = cal.dateInterval(of: .weekOfYear, for: weekAnchor) else { return [] }
        var result: [Date] = []
        var cursor = weekInterval.start
        for _ in 0..<7 {
            result.append(cursor)
            cursor = cal.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }
        return result
    }
    
    private func dayNumber(_ date: Date) -> Int {
        Calendar.current.component(.day, from: date)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        selected.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(daysOfWeek, id: \.self) { day in
                let number = dayNumber(day)
                let stamped = stampedDays.contains(number)
                
                Circle()
                    .fill(stamped ? Color("CustomBlue5") : Color("CustomLightGray"))
                    .frame(width: 31, height: 31)
                    .overlay {
                        if(stamped) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(hex: " #FFFFFF"))
                                .frame(width: 16.69, height: 16.69)
                        }
                    }
            }
        }
        .padding(.horizontal, 11)
    }
}

#Preview {
    WeekView(vm: WalkingRecordViewModel())
}
