

import Foundation
import Combine
import UIKit

class UserManager: ObservableObject {
    static let shared = UserManager()
    private let serverManager = ServerManager.shared
    var userId: Int? = nil
    @Published var name: String = ""
    @Published var birthYear: String = ""
    @Published var birthMonth: String = ""
    @Published var birthDay: String = ""
    @Published var nickname: String = ""
    @Published var profileImage: UIImage? = nil
    
    @Published var termsAgreed: Bool = false
    @Published var privacyAgreed: Bool = false
    @Published var locationAgreed: Bool = false
    @Published var marketingConsent: Bool = false
    
    @Published var targetWalkCount: Int = 1
    @Published var targetStepCount: Int = 1000
    
    @Published var level: Int = 1
    @Published var grade: String = "SEED"
    var characterInfo: CharacterInfo = CharacterInfo(level: 1, grade: "SEED", nickName: "", currentGoalSequence: 0)

    @Published var continuousAttendance: Int = 1
    private let defaults = UserDefaults.standard
    private let lastOpenedKey = "MyPage.lastOpenedDate"
    private let streakKey = "MyPage.streakCount"
    
    func logOut() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.logOut(token: accessToken)
            AuthManager.shared.reset()
            UserManager.shared.reset()
        } catch {
            debugPrint("로그아웃 실패")
        }
    }
    
    func reset() {
        userId = nil
        name = ""
        birthYear = ""
        birthMonth = ""
        birthDay = ""
        nickname = ""
        profileImage = nil
        
        termsAgreed = false
        privacyAgreed = false
        locationAgreed = false
        marketingConsent = false
        
        targetWalkCount = 1
        targetStepCount = 1000
        
        level = 1
        grade = "SEED"
        
        continuousAttendance = 1
    }

    func postUsersPolicy(termsAgreed: Bool, privacyAgreed: Bool, locationAgreed: Bool, marketingConsent: Bool) async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            try await serverManager.postUsersPolicy(token: accessToken, termsAgreed: termsAgreed, privacyAgreed: privacyAgreed, locationAgreed: locationAgreed, marketingConsent: marketingConsent)
            return true
        } catch {
            return false
        }
    }
    
    func postUsersNickname() async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            try await serverManager.postUsersNickname(token: accessToken, nickname: nickname)
            return true
        } catch {
            return false
        }
    }
    
    func postUsersBirthDate() async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            let birthDate = birthYear + "-" + birthMonth + "-" + birthDay
            try await serverManager.postUsersBirthDate(token: accessToken, birthDate: birthDate)
            return true
        } catch {
            debugPrint("postUsersBirthDate 실패")
            return false
        }
    }
    
    func postGoals(goals: Goals) async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            try await serverManager.postGoals(token: accessToken, goals: goals)
            return true
        } catch {
            debugPrint("postGoals 실패")
            return false
        }
    }
    
    func cancelMembership() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.cancelMembership(token: accessToken, nickName: nickname, birthDate: birthYear + "-" + birthMonth + "-" + birthDay)
            AuthManager.shared.authSate = .LogOut
        } catch {
            debugPrint("로그아웃 실패")
        }
    }
    
    func getUserInfo() async {
        guard let userInfo = await getUsers() else { return }
        userId = userInfo.userId
        updateAttendanceIfNeeded(for: String(userId ?? 0))
        nickname = userInfo.nickname ?? ""
        guard let birthDate = userInfo.birthDate?.split(separator: "-") else { return }
        if(birthDate.count == 3) {
            birthYear = String(birthDate[0])
            birthMonth = String(birthDate[1])
            birthDay = String(birthDate[2])
        }
        await profileImage = (userInfo.imageName ?? "DefualtImage").loadImage()
        _ = await getGoals()
        await postFCMToken()
        await getWalkList()
    }
    
    func getUsers() async -> UserProfile? {
        guard let authToken = AuthManager.shared.authToken else {
            debugPrint("authToken 없음")
            return nil
        }
        var result: UserProfile?
        do {
            result = try await serverManager.getUsers(token: authToken.accessToken)
            debugPrint("getUsers: \(result!)")
        } catch {
            debugPrint("getUsers 실패")
        }
        return result
    }
    
    func getGoals() async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            let goals = try await serverManager.getGoals(token: accessToken)
            targetStepCount = goals.targetStepCount
            targetWalkCount = goals.targetWalkCount
            return true
        } catch {
            debugPrint("getGoals Error")
            return false
        }
    }
    
    func postFCMToken() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken,
              let fcmTokenString = UserDefaults.standard.string(forKey: "fcmToken")
        else { return }
        
        let fcmToken = FCMToken(
            id: 0,
            token: fcmTokenString,
            deviceType: "iOS",
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "")
        do {
            _ = try await serverManager.postFCMToken(token: accessToken, fcmToken: fcmToken)
        } catch {
            debugPrint("postFCMToken 실패")
        }
    }
    
    func getGrade() -> String {
        switch(grade) {
        case "SEED": return "씨앗"
        case "SPROUT": return "새싹"
        case "TREE": return "나무"
        default: return "씨앗"
        }
    }
    
    func getWalkList() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            let walks = try await serverManager.getWalkList(token: accessToken)
            print("walks: \(walks)")
        } catch {
            print("getWalkList 실패")
        }
    }
    
    func updateAttendanceIfNeeded(for userId: String, now: Date = Date()) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let todayTimestamp = startOfToday.timeIntervalSince1970

        var attendanceDict = defaults.dictionary(forKey: "attendanceDict") as? [String: [String: Any]] ?? [:]

        // 기본값도 TimeInterval 기준
        var userInfo = attendanceDict[userId] ?? [
            "streak": 1,
            "lastDate": todayTimestamp
        ]

        let lastTimestamp = userInfo["lastDate"] as? TimeInterval ?? todayTimestamp
        let lastDate = Date(timeIntervalSince1970: lastTimestamp)

        var streak = userInfo["streak"] as? Int ?? 1

        let startOfLast = calendar.startOfDay(for: lastDate)

        if startOfToday != startOfLast {
            let days = calendar.dateComponents([.day], from: startOfLast, to: startOfToday).day ?? 0

            if days == 1 {
                streak += 1
            } else if days > 1 {
                streak = 1
            }
        } else {
            // 오늘 이미 체크됨
            return
        }

        userInfo["streak"] = streak
        userInfo["lastDate"] = todayTimestamp
        attendanceDict[userId] = userInfo
        defaults.set(attendanceDict, forKey: "attendanceDict")

        continuousAttendance = streak
    }
}
