import Foundation
import Combine

class AlimManagerViewModel: ObservableObject {
    private let serverManager = ServerManager.shared
    
    @Published var notificationEnabled = false
    @Published var goalNotificationEnabled = false
    @Published var missionNotificationEnabled = false
    @Published var friendNotificationEnabled = false
    @Published var marketingPushEnabled = false
    
    
    
    func loadView() async {
        guard let notificationSetting = await getNotificationSetting() else { return }
        notificationEnabled = notificationSetting.notificationEnabled
        goalNotificationEnabled = notificationSetting.goalNotificationEnabled
        missionNotificationEnabled = notificationSetting.missionNotificationEnabled
        friendNotificationEnabled = notificationSetting.friendNotificationEnabled
        marketingPushEnabled = notificationSetting.marketingPushEnabled
    }
    
    func getNotificationSetting() async -> NotificationSetting? {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else {
            debugPrint("authToken 없음")
            return nil
        }
        var result: NotificationSetting?
        do {
            result = try await serverManager.getNotificationSetting(token: accessToken)
        } catch {
            debugPrint("getNotificationSetting 실패")
        }
        return result
    }
    
    func patchNotificationSetting() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else {
            debugPrint("authToken 없음")
            return
        }
        let notificationSetting = NotificationSetting(
            notificationEnabled: notificationEnabled,
            goalNotificationEnabled: goalNotificationEnabled,
            missionNotificationEnabled: missionNotificationEnabled,
            friendNotificationEnabled: friendNotificationEnabled,
            marketingPushEnabled: marketingPushEnabled)
        do {
            try await serverManager.patchNotificationSetting(token: accessToken, notificationSetting: notificationSetting)
        } catch {
            debugPrint("patchNotificationSetting 실패")
        }
    }
}
