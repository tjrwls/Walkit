//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import SwiftUI

struct GoalSettingView: View {
    @ObservedObject var vm: SignUpViewModel
    @Environment(\.dismiss) private var dismiss

    init(vm: SignUpViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            HStack {   
                Text("")
                    .font(.system(size: 12))
                    .foregroundStyle(Color("CustomGray"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 32)
            
            Text("목표 설정")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.white))
                .modifier(CapsuleBackground(backgroundColor: Color("CustomBlack")))
                .padding(.bottom, 12)
            
            Text("\(vm.nickname)님,\n워킷과 함께 걸어봐요!")
                .font(.system(size: 24, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.bottom, 42)

            VStack(alignment: .leading, spacing: 0) {
                Text("주간 산책 횟수")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("CustomBlack"))
                    .padding(.bottom, 2)
                
                Text("최소 1회 ~ 최대 7회")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("CustomLightGray2"))
                    .padding(.bottom, 12)

                HStack(spacing: 0) {
                    valueField(text: formatted(vm.targetWalkCount))
                        .padding(.trailing, 8)
                    
                    minusButton {
                        impact()
                        vm.targetWalkCount = max(vm.weeklyRange.lowerBound, vm.targetWalkCount - 1)
                    }
                    .padding(.trailing, 4)
                    
                    plusButton {
                        impact()
                        vm.targetWalkCount = min(vm.weeklyRange.upperBound, vm.targetWalkCount + 1)
                    }
                }
            }
            .padding(.bottom, 32)
            
            VStack(alignment: .leading) {
                Text("일일 걸음 수")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("CustomBlack"))
                    .padding(.bottom, 2)
                
                Text("최소 1,000보 ~ 최대 30,000보")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("CustomLightGray2"))
                    .padding(.bottom, 12)
                
                HStack(spacing: 5) {
                    valueField(text: formatted(vm.targetStepCount))
                    minusButton {
                        impact()
                        vm.targetStepCount = max(vm.stepsRange.lowerBound, vm.targetStepCount - 1000)
                    }
                    plusButton {
                        impact()
                        vm.targetStepCount = min(vm.stepsRange.upperBound, vm.targetStepCount + 1000)
                    }
                }
            }
            
            Spacer()
            
            
            HStack {
                OutlineActionButton(title: "이전으로") { dismiss() }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
                
                FilledActionButton(title: "다음으로", isEnable: .constant(true), isRightChevron: false) {
                    Task {
                        vm.isShowingProgress = true
                        await vm.postGoals()
                        vm.isShowingProgress = false
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 20)
        .background(Color("CustomLightGray6"))
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func valueField(text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(Color("CustomBlack"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 11)
            .padding(.leading, 16)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.white))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("CustomBlack"), lineWidth: 1)
                    }
            }
    }
    
    func minusButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "minus")
                .font(.headline)
                .foregroundStyle(Color("CustomBlack"))
                .frame(width: 48, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color("CustomBlack"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "FFFFFF"))
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("감소")
    }
    
    func plusButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.headline)
                .foregroundStyle(Color(.white))
                .frame(width: 48, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color("CustomBlack"))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("증가")
    }
    
    func formatted(_ value: Int) -> String {
        vm.numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    func impact() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
}

#Preview {
    GoalSettingView(vm: SignUpViewModel())
}
