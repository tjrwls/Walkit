import Combine
import SwiftUI

class NotificationViewModel: ObservableObject {
    let serverManager = ServerManager.shared
    @Published var notificationItems: [NotificationItem] = []
    
    func loadView() {
        Task {
            await getNotificationList()
        }
    }
    
    func getNotificationList() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            notificationItems = try await serverManager.getNotificationList(token: accessToken, count: 20)
            debugPrint("getNotificationList: \(notificationItems)")
        } catch {
            debugPrint("getNotificationList 실패")
        }
    }
    
    func deleteNotificationList(notiId: Int) async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.deleteNotificationList(token: accessToken, notiId: notiId)
            await getNotificationList()
        } catch {
            debugPrint("deleteNotificationList 실패")
        }
    }
    
    func deleteFollower(nickName: String) async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.deleteFollowers(token: accessToken, nickname: nickName)
            await getNotificationList()
        } catch {
            debugPrint("deleteFollower 실패")
        }
    }
    
    func patchFollow(nserNickname: String) async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
             try await serverManager.patchfollows(token: accessToken, userNickname: nserNickname)
        } catch {
            debugPrint("patchFollow 실패")
        }
    }
}
