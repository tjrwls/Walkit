
import SwiftUI

struct CustomCompactWheelPicker: View {
    @State private var showWheel = false
    @State private var minute = 10

    var body: some View {
        ZStack {
            // 기본 내용
            VStack(alignment: .leading, spacing: 8) {
                Text("Please select minutes")

                Button {
                    withAnimation(.spring) {
                        showWheel.toggle()
                    }
                } label: {
                    Text("\(minute) min")
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding()

            // DatePicker처럼 아래에 휠 오픈
            if showWheel {
                VStack {
                    Spacer().frame(height: 80) // pill 바로 밑 정도 위치
                    VStack {
                        Picker("", selection: $minute) {
                            ForEach(0..<60) { m in
                                Text("\(m) min").tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 180)

                        Button("완료") {
                            withAnimation(.spring) {
                                showWheel = false
                            }
                        }
                        .padding(.bottom, 8)
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 8)

                    Spacer()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
