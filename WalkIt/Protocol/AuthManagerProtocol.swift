//
//  File.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import KakaoSDKAuth
import SwiftUI
import AuthenticationServices

protocol AuthManagerProtocol {
    var authSate: AuthState { get set }
    var errorMessage: String? { get set }
    var kakaoToken: OAuthToken? { get set }
    
    func kakaoLogin()
    func naverLogin() async
    func handleAppleSignIn(result: Result<ASAuthorization, Error>)
}
