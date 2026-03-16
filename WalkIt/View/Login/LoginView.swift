//
//  LoginView.swift
//  WalkIt
//
//  Created by 조석진 on 12/12/25.
//

import SwiftUI
import KakaoSDKUser
import NidThirdPartyLogin
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var vm: LoginViewModel
    
    init(vm: LoginViewModel) { self.vm = vm }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color("CustomBlue6"),
                    Color("CustomLightBlue")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack {
                Spacer()
                
                Image("LoginLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                HStack {
                    Spacer()
                    ZStack(alignment: .trailing) {
                        Image("LoginShadow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 146)
                            .offset(y: 140)
                        
                        Image("LoginCharacter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                    }
                }
                
                
                Button {
                    vm.kakaoLogin()
                } label: {
                    Image("KakaoLogin")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 342, maxHeight: 53)
                }
                
                Button {
                    Task {
                        await vm.naverLogin()
                    }
                } label: {
                    Image("NaverLogin")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 342, maxHeight: 53)
                }
                
                ZStack {
                    SignInWithAppleButton(onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    }, onCompletion: { result in
                        vm.handleAppleSignIn(result: result)
                    })
                    .frame(maxWidth: 330, maxHeight: 50)
                    
                    Button {
                    } label: {
                        Image("AppleLogin")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 342, maxHeight: 53)
                    }
                    .allowsHitTesting(false)
                }
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            Task { @MainActor in
                await AuthManager.shared.checkAutoLogin()
            }
        }
        .animation(.easeOut, value: vm.showSignUpView)
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView(vm: LoginViewModel())
}
