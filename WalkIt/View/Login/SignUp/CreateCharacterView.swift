//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import SwiftUI

struct CreateCharacterView: View {
    @ObservedObject var vm: SignUpViewModel
    @FocusState private var isTextFieldFocused: Bool

    init(vm: SignUpViewModel) { self.vm = vm }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    vm.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color("CustomBlack"))
                        .frame(width: 13.15, height: 13.15)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 21)
                }
            }
            .padding(.bottom, 32)
            
            Text("준비 단계")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.white))
                .modifier(CapsuleBackground(backgroundColor: Color("CustomBlack")))
                .padding(.bottom, 12)
            
            Text("닉네임을 만들어주세요")
                .font(.system(size: 24))
                .padding(.bottom, 66)
            
            Image("NickNameCharacter")
                .resizable()
                .scaledToFit()
                .frame(width: 204, height: 194)
                .padding(.bottom, 36)
            
            TextField("한글 또는 영어만 사용 가능합니다", text: $vm.nickname)
                .font(.system(size: 14))
                .focused($isTextFieldFocused)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color("CustomBlack"))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .overlay {
                    Text("\(vm.nickname.count)/20자")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("CustomGray"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 20)
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.white))
                        .overlay {
                            if(vm.isDuplicate) {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("CustomPink3"), lineWidth: 1)
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isTextFieldFocused ? Color("CustomBlack") : Color("CustomGray"), lineWidth: 1)
                            }
                        }
                }
                .padding(.bottom, 4)
                .onChange(of: vm.nickname) { oldValue, newValue in
                    if(newValue.count > 20) { vm.nickname = oldValue }
                    if(!vm.isValidText(vm.nickname)) {
                        vm.isDuplicateString = "숫자와 특수문자는 사용 불가합니다"
                        vm.isDuplicate = true
                    } else {
                        vm.isDuplicate = false
                    }
                }
            
            if(vm.isDuplicate) {
                HStack {
                    Text(vm.isDuplicateString)
                        .font(.subheadline)
                        .foregroundStyle(Color("CustomPink3"))
                    Spacer()
                }
            }
            
            Spacer()
            
            FilledActionButton(title: "다음으로", isEnable: .constant(true), isRightChevron: false) {
                Task {
                    if(vm.isValidText(vm.nickname)) {
                        vm.isShowingProgress = true
                        await vm.postUsersNickname()
                        vm.isShowingProgress = false
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 16)
        .background(Color("CustomLightGray6"))
        .navigationTitle("")
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { isTextFieldFocused = true }
        .onTapGesture { isTextFieldFocused = false }
    }
}


#Preview {
    CreateCharacterView(vm: SignUpViewModel())
}

