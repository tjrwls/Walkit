//
//  GoalManagerView.swift
//  WalkIt
//
//  Created by 조석진 on 12/15/25.
//
import SwiftUI

struct GoalsManagerView: View {
    @StateObject var vm: GoalsManagerViewModel
    
    @Binding var path: NavigationPath
    init(vm: GoalsManagerViewModel, path: Binding<NavigationPath>) {
        _vm = StateObject(wrappedValue: GoalsManagerViewModel())
        self._path = path
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button {
                        if(vm.isChangedData()) {
                            vm.showSaveAlert = true
                        } else {
                            path = NavigationPath()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color("CustomBlack"))
                            .frame(width: 9, height: 16)
                    }
                    .frame(width: 24, height: 24)
                    .padding(.leading, 14)
                    .padding(.trailing, 5)
                    
                    Spacer()
                    
                    Text("목표 관리")
                        .figmaText(fontSize: 20, weight: .semibold)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 19)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                
                Divider()
                    .foregroundStyle(Color("CustomLightGray"))
                
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        if(vm.isEditEanble) {
                            HStack(alignment: .top, spacing: 0) {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundStyle(Color("CustomBlack"))
                                    .frame(width: 16.67)
                                    .padding(.top, 16.67)
                                    .padding(.leading, 16.67)
                                    .padding(.trailing, 9.67)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("목표는 1주일 기준으로 설정 가능합니다.")
                                        .figmaText(fontSize: 14, weight: .medium)
                                        .foregroundStyle(Color("CustomBlack"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("목표는 한 달에 한 번만 변경 가능합니다")
                                        .figmaText(fontSize: 12, weight: .regular, lineHeightPercent: 1.3)
                                        .foregroundStyle(Color("CustomGray"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("변경된 목표는 목표 달성율과 캐릭터 레벨업에 영향을 미칩니다")
                                        .figmaText(fontSize: 12, weight: .regular, lineHeightPercent: 1.3)
                                        .foregroundStyle(Color("CustomGray"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.vertical, 12)
                                .padding(.trailing, 12)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color("CustomLightGray"))
                                    .stroke(Color("CustomLightGray2"), lineWidth: 1)
                            )
                            .padding(.bottom, 20)
                        }
                        Text("주간 산책 횟수")
                            .figmaText(fontSize: 16, weight: .medium)
                            .foregroundStyle(Color("CustomBlack"))
                            .padding(.bottom, 2)
                        Text("최소 1회 ~ 최대 7회")
                            .figmaText(fontSize: 12, weight: .medium)
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
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("일일 걸음 수")
                            .figmaText(fontSize: 16, weight: .medium)
                            .foregroundStyle(Color("CustomBlack"))
                            .padding(.bottom, 2)
                        
                        Text("최소 1,000보 ~ 최대 30,000보")
                            .figmaText(fontSize: 12, weight: .medium)
                            .foregroundStyle(Color("CustomLightGray2"))
                            .padding(.bottom, 12)
                        
                        HStack(spacing: 0) {
                            valueField(text: formatted(vm.targetStepCount))
                                .padding(.trailing, 8)
                            
                            minusButton {
                                impact()
                                vm.targetStepCount = max(vm.stepsRange.lowerBound, vm.targetStepCount - 1000)
                            }
                            .padding(.trailing, 4)
                            
                            plusButton {
                                impact()
                                vm.targetStepCount = min(vm.stepsRange.upperBound, vm.targetStepCount + 1000)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    infoBanner
                    HStack(spacing: 8) {
                        OutlineActionButton(title: "초기화") {
                            vm.targetWalkCount = 1
                            vm.targetStepCount = 1000
                        }
                        
                        FilledActionButton(title: "저장하기", isEnable: $vm.isEditEanble, isRightChevron: false) {
                            Task {
                                await vm.putGoals()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .padding(.top, 16)
                .background(.white)
            }
            
            if(vm.showSaveAlert) {
                Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        vm.showSaveAlert = false
                    }
                VStack(spacing: 0) {
                    Text("변경된 사항이 있습니다")
                        .figmaText(fontSize: 18, weight: .semibold)
                        .padding(.bottom, 4)

                    Text("저장하시겠습니까?")
                        .figmaText(fontSize: 14, weight: .regular)
                        .foregroundStyle(Color("CustomGray"))
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 8) {
                        Button {
                            path = NavigationPath()
                        } label: {
                            Text("아니요")
                                .figmaText(fontSize: 16, weight: .semibold)
                                .foregroundStyle(Color("CustomGreen2"))
                                .padding(.vertical, 14.5)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("CustomGreen2"), lineWidth: 1)
                                )
                        }
                        
                        Button {
                            Task {
                                vm.isSavingProgress = true
                                await vm.putGoals()
                                vm.isSavingProgress = false
                                path = NavigationPath()
                            }
                        } label: {
                            Text("예")
                                .figmaText(fontSize: 16, weight: .semibold)
                                .foregroundStyle(Color(.white))
                                .padding(.vertical, 14.5)
                                .frame(maxWidth: .infinity)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("CustomBlack"))
                                )
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.white))
                )
                .padding(32)
            }
            if(vm.isSavingProgress) {
                Color("CustomBlack2").opacity(0.5).ignoresSafeArea()
                ProgressView()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            Task { @MainActor in
                await vm.getGoals()
            }
        }
    }
}

// MARK: - Subviews
private extension GoalsManagerView {
    var infoBanner: some View {
        VStack {
            if(!vm.isEditEanble) {
                HStack(alignment: .top, spacing: 0) {
                    Image(systemName: "xmark")
                        .frame(width: 13.15)
                        .foregroundStyle(Color("CustomRed"))
                        .padding(.top, 17.03)
                        .padding(.leading, 17.22)
                        .padding(.trailing, 13.63)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("이번 달 목표 수정이 불가능합니다")
                            .figmaText(fontSize: 14, weight: .semibold)
                            .foregroundStyle(Color("CustomRed"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("목표는 한 달에 한 번만 변경 가능합니다.")
                            .figmaText(fontSize: 12, weight: .regular, lineHeightPercent: 1.3)
                            .foregroundStyle(Color("CustomRed"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .padding(.trailing, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color("CustomLightPink"))
                        .stroke(Color("CustomPink"), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
    
    func valueField(text: String) -> some View {
        Text(text)
            .figmaText(fontSize: 16, weight: .regular)
            .foregroundStyle(Color("CustomBlack"))
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 8)
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
                .foregroundStyle(Color("CustomBlack"))
                .frame(width: 11.67, height: 1.67)
                .padding(.vertical, 19.17)
                .padding(.horizontal, 14.17)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color("CustomBlack"), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "FFFFFF"))
                        )
                )
        }
        .accessibilityLabel("감소")
    }
    
    func plusButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.headline)
                .foregroundStyle(Color(.white))
                .frame(width: 15)
                .padding(12.5)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color("CustomBlack"))
                )
        }
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
    GoalsManagerView(vm: GoalsManagerViewModel(), path: .constant(NavigationPath()))
}
