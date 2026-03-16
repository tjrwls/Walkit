
import SwiftUI

struct YearMonthWheelPicker: View {
    @Binding var monthAnchor: Date
    var onClose: (() -> Void)?

    // 연 범위: 필요에 맞게 조정(예: 현재 연도 ± 10년)
    private let years: [Int]
    private let months = Array(1...12)

    init(monthAnchor: Binding<Date>, onClose: (() -> Void)? = nil, yearRange: ClosedRange<Int>? = nil) {
        self._monthAnchor = monthAnchor
        self.onClose = onClose
        
        let cal = Calendar.current
        let currentYear = cal.component(.year, from: Date())
        let range = yearRange ?? (currentYear-100...currentYear)
        self.years = Array(range)
    }

    private var selectedYear: Int {
        Calendar.current.component(.year, from: monthAnchor)
    }
    private var selectedMonth: Int {
        Calendar.current.component(.month, from: monthAnchor)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button("완료") {
                    onClose?()
                }
                .font(.headline)
            }
            .padding(.horizontal)

            HStack(spacing: 0) {
                // 연 휠
                Picker("년", selection: Binding(
                    get: { selectedYear },
                    set: { newYear in
                        update(year: newYear, month: selectedMonth)
                    }
                )) {
                    ForEach(years, id: \.self) { y in
                        Text("\(y)년").tag(y)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                // 월 휠
                Picker("월", selection: Binding(
                    get: { selectedMonth },
                    set: { newMonth in
                        update(year: selectedYear, month: newMonth)
                    }
                )) {
                    ForEach(months, id: \.self) { m in
                        Text("\(m)월").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .labelsHidden()
        }
        .padding(.top, 8)
    }

    private func update(year: Int, month: Int) {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        if let d = Calendar.current.date(from: comps) {
            monthAnchor = d
        }
    }
}
