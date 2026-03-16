//
//  NotificationManager.swift
//  WalkIt
//
//  Created by 조석진 on 1/8/26.
//


import SwiftUI
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private init() {}
    
    /// 알림 권한 요청/확인
    func requestAuthorizationIfNeeded()  {
        let center = UNUserNotificationCenter.current()
        debugPrint("requestAuthorizationIfNeeded called")
        
        center.getNotificationSettings { settings in
            debugPrint("Current notification authorization status: \(settings.authorizationStatus.rawValue)")
            switch settings.authorizationStatus {
            case .notDetermined:
                debugPrint("Requesting push permission")
                self.requestPushPermission()
                
            case .denied:
                // 이미 거부 → 앱 설정으로 안내
                debugPrint("Push permission denied, opening settings alert")
                self.showSettingsAlert()
                
            case .authorized, .provisional, .ephemeral:
                // 이미 허용됨 → 바로 등록
                DispatchQueue.main.async {
                    debugPrint("Registering for remote notifications from NotificationManager")
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            @unknown default:
                break
            }
        }
    }
    
    /// 실제 권한 요청
    private func requestPushPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                debugPrint("requestAuthorization error: \(error)")
                return
            }
            
            debugPrint("requestAuthorization granted: \(granted)")
            if granted {
                DispatchQueue.main.async {
                    debugPrint("Registering for remote notifications after permission grant")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                debugPrint("Push permission not granted.")
            }
        }
    }
    
    private func showSettingsAlert() {
        DispatchQueue.main.async { // 현재 활성화된 윈도우씬 찾기
            guard let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else { return }

            let alert = UIAlertController(
                title: "알림 권한 필요",
                message: "산책 알림을 받으려면 설정에서 알림을 허용해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "설정 열기", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })

            rootVC.present(alert, animated: true)
        }
    }

}
