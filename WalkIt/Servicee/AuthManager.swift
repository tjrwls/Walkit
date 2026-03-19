//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import Combine
import KakaoSDKAuth
import KakaoSDKUser
import NidThirdPartyLogin
import AuthenticationServices

enum AuthState {
    case LogOut
    case LogIn
    case SignUp
}

class AuthManager: AuthManagerProtocol, ObservableObject {
    static let shared = AuthManager()
    private let serverManager = ServerManager.shared
    @Published var errorMessage: String?
    @Published var authSate: AuthState = .LogOut
    @Published var authToken: LoginResponse?
    @Published var isShowingProgress: Bool = false
    
    var kakaoToken: OAuthToken?
    var naverToken: AccessToken?
    var appleCredential: ASAuthorizationAppleIDCredential?

    var nickname: String = ""
    var email: String = ""
    var name: String = ""
    var loginType = ""
    
    func reset() {
        errorMessage = nil
        authSate = .LogOut
        authToken = nil
        isShowingProgress = false
        
        kakaoToken = nil
        naverToken = nil
        appleCredential = nil

        nickname = ""
        email = ""
        name = ""
        loginType = ""
    }

    
    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    Task {
                        self?.isShowingProgress = true
                        do {
                            self?.authToken = try await self?.serverManager.login(with: "kakao", token: oauthToken?.accessToken ?? "")
                            KeychainManager.shared.accessToken = self?.authToken?.accessToken ?? ""
                            KeychainManager.shared.refreshToken = self?.authToken?.refreshToken ?? ""
                            let result = await self?.isUsers()
                            self?.isShowingProgress = false
                            self?.getKakaoInfo()
                            if(result ?? false) {
                                self?.authSate = .LogIn
                            } else {
                                self?.authSate = .SignUp
                            }
                            self?.errorMessage = nil
                        } catch let error as NetworkError {
                            self?.isShowingProgress = false
                            self?.handleLoginError(error)
                        } catch {
                            self?.isShowingProgress = false
                            self?.errorMessage = "알 수 없는 오류가 발생했습니다."
                        }
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    Task {
                        self?.isShowingProgress = true
                        do {
                            self?.authToken = try await self?.serverManager.login(with: "kakao", token: oauthToken?.accessToken ?? "")
                            KeychainManager.shared.accessToken = self?.authToken?.accessToken ?? ""
                            KeychainManager.shared.refreshToken = self?.authToken?.refreshToken ?? ""
                            let result = await self?.isUsers()
                            self?.isShowingProgress = false
                            self?.getKakaoInfo()
                            if(result ?? false) {
                                self?.authSate = .LogIn
                            } else {
                                self?.authSate = .SignUp
                            }
                            self?.errorMessage = nil
                        } catch {
                            self?.isShowingProgress = false
                        }
                    }
                }
            }
        }
    }
    
    func getKakaoInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                debugPrint("유저 정보 요청 실패:", error)
                return
            }
            guard let user = user else { return }
            
            self.nickname = user.kakaoAccount?.profile?.nickname ?? ""
            self.email = user.kakaoAccount?.email ?? ""
            self.name = user.kakaoAccount?.name ?? ""
            self.loginType = "카카오"
            
        }
    }
    
    func naverLogin() async {
        do {
            let accessToken = try await requestNaverLogin()
            if accessToken.isExpired {
                self.errorMessage = "네이버 엑세스 토큰이 만료되었습니다."
            } else {
                self.isShowingProgress = true
                self.authToken = try await self.serverManager.login(with: "naver", token: accessToken.tokenString)
                KeychainManager.shared.accessToken = self.authToken?.accessToken ?? ""
                KeychainManager.shared.refreshToken = self.authToken?.refreshToken ?? ""
                let result = await self.isUsers()
                self.isShowingProgress = false
                getNaverInfo()
                if(result) {
                    self.authSate = .LogIn
                } else {
                    self.authSate = .SignUp
                }
                self.errorMessage = nil
            }
        } catch {
            self.isShowingProgress = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func requestNaverLogin() async throws -> AccessToken {
        return try await withCheckedThrowingContinuation { continuation in
            NidOAuth.shared.requestLogin { result in
                switch result {
                case .success(let loginResult):
                    continuation.resume(returning: loginResult.accessToken)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
        
    func getNaverInfo() {
        guard let tokenString = NidOAuth.shared.accessToken?.tokenString else {
            debugPrint("accessToken 없음")
            return
        }

        NidOAuth.shared.getUserProfile(accessToken: tokenString) { result in
            switch result {
            case .success(let profile):
                self.name = profile["name"] ?? ""
                self.nickname = profile["nickname"] ?? ""
                self.email = profile["email"] ?? ""
                self.loginType = "네이버"
                
            case .failure(let error):
                debugPrint("프로필 요청 실패:", error)
            }
        }
    }

    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let identityToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: identityToken, encoding: .utf8)
                else { return }
                
                Task { @MainActor in
                    self.isShowingProgress = true
                    self.authToken = try await self.serverManager.login(with: "apple", token: idTokenString)
                    KeychainManager.shared.accessToken = self.authToken?.accessToken ?? ""
                    KeychainManager.shared.refreshToken = self.authToken?.refreshToken ?? ""
                    let result = await self.isUsers()
                    if(result) {
                        self.isShowingProgress = false
                        self.authSate = .LogIn
                    } else {
                        self.isShowingProgress = false
                        self.authSate = .SignUp
                    }
                }
                
                self.appleCredential = appleIDCredential
                self.errorMessage = nil
            } else {
                self.isShowingProgress = false
                self.errorMessage = "애플 로그인 인증 정보가 올바르지 않습니다."
            }
        case .failure(let error):
            self.isShowingProgress = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    func isUsers() async -> Bool {
        await UserManager.shared.getUserInfo()
        if(UserManager.shared.nickname == "") { return false }
        let result = await UserManager.shared.getGoals()
        return result
    }
 
    func handleCredential(_ credential: ASAuthorizationAppleIDCredential) {
        if let email = credential.email {
            self.email = email
        }
        
        if let fullName = credential.fullName {
            self.name = [fullName.familyName, fullName.givenName]
                .compactMap { $0 }
                .joined()
        }
    }
    
    private func handleLoginError(_ error: NetworkError) {
        switch error {
        case .httpError(let statusCode):
            switch statusCode {
            case 401:
                self.errorMessage = "로그인에 실패했습니다."
                self.authSate = .LogOut

            case 302:
                self.errorMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
                self.authSate = .LogOut

            default:
                self.errorMessage = "서버 오류 (\(statusCode))"
            }

        case .decodingError:
            self.errorMessage = "서버 응답을 처리할 수 없습니다."

        case .invalidURL:
            self.errorMessage = "유효하지 않은 URL입니다."
    
        case .unauthorized:
            self.errorMessage = "유효하지 않은 Token입니다.."
            
        case .unknown(let underlying):
            self.errorMessage = underlying.localizedDescription
        }
        debugPrint("Login Error: \(String(describing: errorMessage))")
    }

    func checkAutoLogin() async {
        self.isShowingProgress = true
        do {
            try await getRefreshToken()
        } catch {
            self.isShowingProgress = false
            print("getRefreshToken 실패")
        }

        let result = await self.isUsers()
        self.isShowingProgress = false
        if(result) {
            self.authSate = .LogIn
        } else {
            self.authSate = .LogOut
        }
    }

    func logout() {
        KeychainManager.shared.clear()
//        UserDefaultsManager.clear()
        authSate = .LogOut
    }
    
    func getRefreshToken() async throws {
        guard let refreshToken = KeychainManager.shared.refreshToken,
        let accessToken = KeychainManager.shared.accessToken else {
            self.isShowingProgress = true
            throw NetworkError.unauthorized
        }
        
        self.authToken = try await serverManager.refreshToken(accessToken: accessToken, refreshToken: refreshToken)
        KeychainManager.shared.accessToken = self.authToken?.accessToken ?? ""
        KeychainManager.shared.refreshToken = self.authToken?.refreshToken ?? ""
    }
}
