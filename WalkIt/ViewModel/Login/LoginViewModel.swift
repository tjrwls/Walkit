import Foundation
import AuthenticationServices
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var showSignUpView = false
    private var authManager: AuthManagerProtocol

    init() {
        authManager = AuthManager.shared
        requestLocation()
    }
    
    func requestLocation() {
        LocationService.shared.requestLocation()
    }
    
    func kakaoLogin() {
        authManager.kakaoLogin()
    }
    func naverLogin() async {
        await authManager.naverLogin()
    }
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        authManager.handleAppleSignIn(result: result)
    }
}
