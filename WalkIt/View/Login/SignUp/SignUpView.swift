//
//  LoginView.swift
//  WalkIt
//
//  Created by 조석진 on 12/12/25.
//

import SwiftUI


struct SignUpView: View {
    @ObservedObject var vm: SignUpViewModel
    @Binding var showSignUpView: AuthState
    
    init(vm: SignUpViewModel, showSignUpView: Binding<AuthState>) {
        self.vm = vm
        _showSignUpView = showSignUpView
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // MARK: 전체 동의
            HStack(spacing: 12) {
                Image(systemName: vm.agreeAll ? "checkmark.square.fill" : "rectangle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(vm.agreeAll ? .green : .gray)
                    .onTapGesture {
                        if(!vm.agreeAll) {
                            vm.agreeAll = true
                            vm.termsAgreed = true
                            vm.privacyAgreed = true
                            vm.locationAgreed = true
                            vm.marketingConsent = true
                        } else {
                            vm.agreeAll = false
                            vm.termsAgreed = false
                            vm.privacyAgreed = false
                            vm.locationAgreed = false
                            vm.marketingConsent = false
                        }
                    }
                Text("전체 동의하기")
                    .font(.system(size: 14, weight: .regular))

                Spacer()
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // MARK: 약관 리스트
            VStack(spacing: 12) {
                AgreementRow(
                    title: "서비스 이용 약관",
                    link: "https://rhetorical-bike-845.notion.site/2d59b82980b98027b91ccde7032ce622",
                    isRequired: true,
                    isChecked: $vm.termsAgreed
                )
                
                AgreementRow(
                    title: "개인 정보 처리 방침",
                    link: "https://rhetorical-bike-845.notion.site/2d59b82980b9805f9f4df589697a27c5",
                    isRequired: true,
                    isChecked: $vm.privacyAgreed
                )
                
                AgreementRow(
                    title: "위치 정보 제공 동의",
                    link: "https://rhetorical-bike-845.notion.site/2d59b82980b980a09bafdba8e79fb042?pvs=74",
                    isRequired: true,
                    isChecked: $vm.locationAgreed
                )
                
                AgreementRow(
                    title: "마케팅 수신 동의 (선택)",
                    link: "https://rhetorical-bike-845.notion.site/2d59b82980b9802cb0e2c7f58ec65ec1?pvs=74",
                    isRequired: false,
                    isChecked: $vm.marketingConsent
                )
            }
            .padding(.vertical, 20)
            .padding(.bottom, 16)
            
            Button {
                Task {
                    vm.isShowingProgress = true
                    await vm.postUsersPolicy()
                    vm.isShowingProgress = false
                }
            } label: {
                Text("가입하기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(vm.isAllRequiredAgreed ? Color(.white) : Color("CustomGray"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(vm.isAllRequiredAgreed ? Color("CustomGreen2") : Color("CustomLightGray4"))
                    )
            }
            .disabled(!vm.isAllRequiredAgreed)
            
            
            Button("닫기") {
                showSignUpView = .LogOut
            }
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.bottom, 34)
        .onChange(of: vm.termsAgreed) { vm.syncAgreeAll() }
        .onChange(of: vm.privacyAgreed) { vm.syncAgreeAll() }
        .onChange(of: vm.locationAgreed) { vm.syncAgreeAll() }
        .onChange(of: vm.marketingConsent) { vm.syncAgreeAll() }
    }
}

struct AgreementRow: View {
    let title: String
    let link: String
    let isRequired: Bool
    @Binding var isChecked: Bool

    var body: some View {
        HStack {
            CheckBox(isChecked: $isChecked)
            HStack(spacing: 2) {
                Link(title, destination: URL(string: link)!)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color("CustomBlack"))
                
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
            }

            Spacer()

            VStack(alignment: .center) {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .bold()
                    .frame(width: 5.46, height: 9.29)
            }
            .frame(width: 20, height: 20)
        }
        .padding(.vertical, 4.5)
    }
}


struct CheckBox: View {
    @Binding var isChecked: Bool

    var body: some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "rectangle")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(isChecked ? .green : .gray)
            .onTapGesture {
                isChecked.toggle()
            }
    }
}


#Preview {
    SignUpView(vm: SignUpViewModel(), showSignUpView: .constant(.SignUp))
}
