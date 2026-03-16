//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import SwiftUI

struct BirthYearView: View {
    @ObservedObject var vm: SignUpViewModel
    @FocusState private var yearTextFieldFocused: Bool
    @FocusState private var monthTextFieldFocused: Bool
    @FocusState private var dayTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(vm: SignUpViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    vm.goNext(.GoalSettingView)
                } label: {
                    Text("건너뛰기")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("CustomGray"))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 24)
            
            Text("연령 확인")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .modifier(CapsuleBackground(backgroundColor: Color("CustomBlack")))
                .padding(.bottom, 12)
            
            Text("\(vm.nickname)님,\n생년월일을 입력해주세요")
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .medium))
                .padding(.bottom, 32)
            
            HStack(spacing: 2) {
                Text("생년월일")
                    .font(.system(size: 14, weight: .medium))
                    
                Text("*")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("CustomRed2"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
            
            Text("생년월일 8자리를 입력해주세요")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color("CustomGray"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)
            
            HStack(spacing: 8) {
                TextField("YYYY", text: $vm.year)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.vertical, 11)
                    .padding(.leading, 16)
                    .keyboardType(.numberPad)
                    .focused($yearTextFieldFocused)
                    .background { Color(.white)}
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if(!vm.isInvalidBirthDateText) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("CustomRed"))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(yearTextFieldFocused ? Color("CustomBlack") : Color("CustomLightGray"), lineWidth: 1)
                        }
                    }
                    .onChange(of: vm.year) { oldValue, newValue in
                        if(newValue.count > 4) { vm.year = oldValue }
                        vm.setBirthDateEnable()
                    }

                
                TextField("MM", text: $vm.month)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.vertical, 11)
                    .padding(.leading, 16)
                    .keyboardType(.numberPad)
                    .focused($monthTextFieldFocused)
                    .background { Color(.white)}
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if(!vm.isInvalidBirthDateText) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("CustomRed"))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(monthTextFieldFocused ? Color("CustomBlack") : Color("CustomLightGray"), lineWidth: 1)
                        }
                    }
                    .onChange(of: vm.month) { oldValue, newValue in
                        if(newValue.count > 2) { vm.month = oldValue }
                        vm.setBirthDateEnable()
                    }
                    
                
                TextField("DD", text: $vm.day)
                    .font(.system(size: 14, weight: .regular))
                    .padding(.vertical, 11)
                    .padding(.leading, 16)
                    .keyboardType(.numberPad)
                    .focused($dayTextFieldFocused)
                    .background { Color(.white)}
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if(!vm.isInvalidBirthDateText) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("CustomRed"))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(dayTextFieldFocused ? Color("CustomBlack") : Color("CustomLightGray"), lineWidth: 1)
                        }
                    }
                    .onChange(of: vm.day) { oldValue, newValue in
                        if(newValue.count > 2) { vm.day = oldValue }
                        vm.setBirthDateEnable()
                    }
            }
            if(!vm.isInvalidBirthDateText) {
                HStack {
                    Text("올바른 날짜를 입력해주세요")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("CustomPink3"))
                    Spacer()
                }
            }
            
            Spacer()
            
            HStack {
                OutlineActionButton(title: "이전으로") { dismiss() }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
                
                FilledActionButton(title: "다음으로", isEnable: $vm.birthDateEnable, isRightChevron: false) {
                    Task {
                        if(vm.isVaildBirthDate()) {
                            vm.isInvalidBirthDateText = true
                            let result = vm.checkBirthDate()
                            if(result) { await vm.postUsersBirthDate() }
                        } else {
                            vm.isInvalidBirthDateText = false
                        }
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
        .onTapGesture {
            yearTextFieldFocused = false
            monthTextFieldFocused = false
            dayTextFieldFocused = false
        }
    }
}


#Preview {
    BirthYearView(vm: SignUpViewModel())
}
