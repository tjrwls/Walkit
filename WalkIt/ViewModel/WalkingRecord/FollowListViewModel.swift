

import Combine
import SwiftUI

class FollowListViewModel: ObservableObject {
    let serverManager = ServerManager.shared
    @Published var follows: [Follow] = []
    @Published var followNickname: String = ""
    @Published var searchUsers: [SearchUsers] = []
    @Published var isShowDeleteAlert = false
    @Published var selectedNickname = ""
    
    func loadView() {
        Task {
            await getFollows()
        }
    }
    
    func getFollows() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            follows = try await serverManager.getFollows(token: accessToken)
            debugPrint("getFollows: \(follows)")
        } catch {
            debugPrint("getFollows 실패")
        }
    }
    
    func isValidText(_ text: String) -> Bool {
        if(text.count < 1) { return false }
        for char in text {
            let scalar = char.unicodeScalars.first!.value
            // 완성형 한글
            if ("\u{AC00}"..."\u{D7A3}").contains(Character(UnicodeScalar(scalar)!)) {
                continue
            }
            // 영어(대소문자)
            if (char >= "a" && char <= "z") || (char >= "A" && char <= "Z") {
                continue
            }
            return false
        }
        return true
    }
 
    func deleteFollows(nickname: String) async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.deleteFollow(token: accessToken, userNickname: nickname)
        } catch {
            debugPrint("deleteFollows 실패")
        }
    }

}
