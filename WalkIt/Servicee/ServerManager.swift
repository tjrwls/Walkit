//
//  ServerManager.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import Foundation
import UIKit

final class ServerManager {
    static let shared = ServerManager()
    private let networkClient = NetworkClient()
    private var baseURL = ""

    private init() {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else { return }
        baseURL = url
    }

    // 예시: 로그인 API
    func login(with provider: String, token: String) async throws -> LoginResponse {
        debugPrint("로그인 token: \(token)")
        guard let url = URL(string: baseURL + "/auth/\(provider)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = [
            "accessToken": token
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        debugPrint("서버 request")
        return try await networkClient.request(request, responseType: LoginResponse.self)
    }
    
    func logOut(token: String) async throws {
        debugPrint("로그아웃 token: \(token)")
        guard let url = URL(string: baseURL + "/auth/logout") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        try await networkClient.requestVoid(request)
    }
    
    func refreshToken(accessToken: String, refreshToken: String) async throws -> LoginResponse {
        debugPrint("리프레쉬 token: \(refreshToken)")
        guard let url = URL(string: baseURL + "/auth/refresh") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = [
            "refreshToken": refreshToken
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return try await networkClient.request(request, responseType: LoginResponse.self, isRetry: true)
    }
    
    func cancelMembership(token: String, nickName: String, birthDate: String) async throws {
        debugPrint("회원탈퇴 token: \(token)")
        guard let url = URL(string: baseURL + "/users") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let body: [String: Any] = [
            "nickname": nickName,
            "birthDate": birthDate
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        try await networkClient.requestVoid(request)
    }

    // 예시: 프로필 조회 API
    func fetchUserProfile(token: String) async throws -> UserProfile {
        guard let url = URL(string: "https://your-backend.com/api/profile") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return try await networkClient.request(request, responseType: UserProfile.self)
    }
    
    func postUsersPolicy(token: String, termsAgreed: Bool, privacyAgreed: Bool, locationAgreed: Bool, marketingConsent: Bool) async throws {
        guard let url = URL(string: baseURL + "/users/policy") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = [
            "termsAgreed": termsAgreed,
            "privacyAgreed": privacyAgreed,
            "locationAgreed": locationAgreed,
            "marketingConsent": marketingConsent
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        try await networkClient.requestVoid(request)
    }
    
    func postUsersNickname(token: String, nickname: String) async throws {
        guard let url = URL(string: baseURL + "/users/nickname/\(nickname)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        try await networkClient.requestVoid(request)
    }
    
    func postUsersBirthDate(token: String, birthDate: String) async throws {
        guard let url = URL(string: baseURL + "/users/birth-date/\(birthDate)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        try await networkClient.requestVoid(request)
    }
    
    func getUsers(token: String) async throws -> UserProfile {
        guard let url = URL(string: baseURL + "/users") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: UserProfile.self)
    }
    
    func putUsers(token: String, nickname: String, birthDate: String) async throws {
        guard let url = URL(string: baseURL + "/users") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let body: [String: Any] = [
            "nickname": nickname,
            "birthDate": birthDate
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        try await networkClient.requestVoid(request)
    }

    func putUsersImage(token: String, image: UIImage) async throws {
        guard let url = URL(string: baseURL + "/users/image") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            return
        }
        
        let boundary = UUID().uuidString
        let body = createMultipartBody(
            boundary: boundary,
            data: imageData,
            fileName: "image.jpg",
            mimeType: "image/jpeg",
            fieldName: "image"
        )
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        try await networkClient.requestVoid(request)
    }
    
    
    private func createMultipartBody(boundary: String, data: Data, fileName: String, mimeType: String, fieldName: String) -> Data {
        var body = Data()

        guard
            let boundaryStart = "--\(boundary)\r\n".data(using: .utf8),
            let contentDisposition = "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8),
            let contentType = "Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8),
            let lineBreak = "\r\n".data(using: .utf8),
            let boundaryEnd = "--\(boundary)--\r\n".data(using: .utf8)
        else {
            return Data()
        }

        body.append(boundaryStart)
        body.append(contentDisposition)
        body.append(contentType)
        body.append(data)
        body.append(lineBreak)
        body.append(boundaryEnd)

        return body
    }

    func getNotificationSetting(token: String) async throws -> NotificationSetting {
        guard let url = URL(string: baseURL + "/notification/setting") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: NotificationSetting.self)
    }
    
    func patchNotificationSetting(token: String, notificationSetting: NotificationSetting) async throws {
        guard let url = URL(string: baseURL + "/notification/setting") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        let body: [String: Any] = [
            "notificationEnabled": notificationSetting.notificationEnabled,
            "goalNotificationEnabled": notificationSetting.goalNotificationEnabled,
            "newMissionNotificationEnabled": notificationSetting.missionNotificationEnabled,
            "friendNotificationEnabled": notificationSetting.friendNotificationEnabled,
            "marketingPushEnabled": notificationSetting.marketingPushEnabled
        ]
    
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        try await networkClient.requestVoid(request)
    }
    
    func getWalkSummary(token: String) async throws ->  WalkSummary {
        guard let url = URL(string: baseURL + "/walk/summary") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: WalkSummary.self)
    }
    
    func getUserWalkSummary(token: String, nickname: String, lat: Double, lon: Double) async throws ->  UserWalkSummary {
        guard let url = URL(string: baseURL + "/users/summary/nickname?nickname=\(nickname)&lat=\(lat)&lon=\(lon)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: UserWalkSummary.self)
    }
    
    func postGoals(token: String, goals: Goals) async throws {
        guard let url = URL(string: baseURL + "/goals") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = [
            "targetStepCount": goals.targetStepCount,
            "targetWalkCount" : goals.targetWalkCount
        ]
    
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        try await networkClient.requestVoid(request)
    }
    
    func getGoals(token: String) async throws ->  Goals {
        guard let url = URL(string: baseURL + "/goals") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: Goals.self)
    }
    
    func putGoals(token: String, goals: Goals) async throws {
        guard let url = URL(string: baseURL + "/goals") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let body: [String: Any] = [
            "targetStepCount": goals.targetStepCount,
            "targetWalkCount" : goals.targetWalkCount
        ]
    
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        try await networkClient.requestVoid(request)
    }
    
    func getWeeklyMission(token: String) async throws ->  WeeklyMission {
        guard let url = URL(string: baseURL + "/missions/weekly/list") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: WeeklyMission.self)
    }
    
    func getHomeResponse(token: String, latitude: Double, longitude: Double) async throws -> HomeResponse {
        guard let url = URL(string: baseURL + "/pages/home?lat=\(latitude)&lon=\(longitude)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: HomeResponse.self)
    }
    
    func getWalkCharacter(token: String, latitude: Double, longitude: Double) async throws -> CharacterInfo {
        guard let url = URL(string: baseURL + "/characters/walks?lat=\(latitude)&lon=\(longitude)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: CharacterInfo.self)
    }
    
    func patchWalk(token: String, walkId: Int, text: String) async throws {
        guard let url = URL(string: baseURL + "/walk/\(walkId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        let body: [String: Any] = [
            "note": text
        ]
    
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func PostWalk(token: String, walkRecord: WalkRecord, image: UIImage?) async throws -> WalkRecord? {
        guard let url = URL(string: baseURL + "/walk/save") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        let walkPoints: [[String: Any]] = (walkRecord.points ?? []).map { point in
            return [
                "latitude": point.latitude ?? 0.0,
                "longitude": point.longitude ?? 0.0,
                "timestampMillis": point.timestampMillis ?? 0
            ]
        }
        
        let walk: [String: Any] = [
            "preWalkEmotion": walkRecord.preWalkEmotion ?? "JOYFUL",
            "postWalkEmotion": walkRecord.postWalkEmotion ?? "JOYFUL",
            "note": walkRecord.note ?? "",
            "points": walkPoints,
            "endTime": walkRecord.endTime ?? 0,
            "startTime": walkRecord.startTime ?? 0,
            "totalDistance": walkRecord.totalDistance ?? 0,
            "stepCount": walkRecord.stepCount ?? 0
        ]
        
        let walkJSONData = try JSONSerialization.data(withJSONObject: walk)
        let imageData = image?.jpegData(compressionQuality: 0.8)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = createMultipartBody(
            boundary: boundary,
            walkJSONData: walkJSONData,
            imageData: imageData
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        debugPrint("request: " + (String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""))
        return try await networkClient.request(request, responseType: WalkRecord.self)
    }
    
    func createMultipartBody(boundary: String, walkJSONData: Data, imageData: Data?, imageName: String = "image.jpg") -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        
        body.appendString("--\(boundary)\(lineBreak)")
        body.appendString("Content-Disposition: form-data; name=\"data\"\(lineBreak)")
        body.appendString("Content-Type: application/json; charset=utf-8\(lineBreak)\(lineBreak)")
        body.append(walkJSONData)
        body.appendString(lineBreak)
        
        if let imageData {
            body.appendString("--\(boundary)\(lineBreak)")
            body.appendString(
                "Content-Disposition: form-data; name=\"image\"; filename=\"\(imageName)\"\(lineBreak)"
            )
            body.appendString("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
            body.append(imageData)
            body.appendString(lineBreak)
        }
        
        body.appendString("--\(boundary)--\(lineBreak)")
        return body
    }
    
    func getFollows(token: String) async throws -> [Follow] {
        guard let url = URL(string: baseURL + "/follows") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: [Follow].self)
    }
    
    func getFollowers(token: String) async throws -> [Follower] {
        guard let url = URL(string: baseURL + "/follows/follower") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: [Follower].self)
    }
    
    func deleteFollows(token: String, nickname: String) async throws {
        guard let url = URL(string: baseURL + "/follows/nickname/\(nickname)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func deleteFollowers(token: String, nickname: String) async throws {
        guard let url = URL(string: baseURL + "/follows/follower/nickname/\(nickname)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func getWalkFollower(token: String, nickname: String, latitude: Double, longitude: Double) async throws -> FollowerWalk {
        guard let url = URL(string: baseURL + "/walk/follower/\(nickname)?lat=\(latitude)&lon=\(longitude)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: FollowerWalk.self)
    }
    
    func postVerifyMission(token: String, userwmId: Int) async throws -> Mission {
        guard let url = URL(string: baseURL + "/missions/weekly/verify/\(userwmId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: Mission.self)
    }
    
    func getMissionCompletedMonthly(token: String, year: Int, month: Int) async throws -> [String] {
        guard let url = URL(string: baseURL + "/missions/completed/monthly?year=\(year)&month=\(month)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: [String].self)
    }
    
    func getPatchWalk(token: String, walkId: Int, note: String) async throws {
        guard let url = URL(string: baseURL + "/walk/update/\(walkId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        let body: [String: Any] = [
            "note": note,
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func getDeleteUserImage(token: String) async throws {
        guard let url = URL(string: baseURL + "/users/image") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func getItems(token: String) async throws -> [CosmeticItem] {
        guard let url = URL(string: baseURL + "/items") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: [CosmeticItem].self)
    }
    
    func postItems(token: String, items: [CosmeticItem]) async throws {
        guard let url = URL(string: baseURL + "/items") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let itemsId: [[String : Any]] = items.map { item in
                return [
                    "itemId": item.itemId
                ]
        }
    
        let body: [String: Any] = [
            "items": itemsId,
            "totalPrice" : items.reduce(0) { $0 + $1.point }
        ]
    
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        try await networkClient.requestVoid(request)
    }
    
    func getPoint(token: String) async throws -> RewardPoint {
        guard let url = URL(string: baseURL + "/users/point") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: RewardPoint.self)
    }
    
    func searchUsers(token: String, userNickname: String) async throws -> [SearchUsers] {
        guard let url = URL(string: baseURL + "/users/nickname?nickname=\(userNickname)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: [SearchUsers].self)
    }
    
    func deleteFollow(token: String, userNickname: String) async throws {
        guard let url = URL(string: baseURL + "/follows/nickname/\(userNickname)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func postFollowing(token: String, userNickname: String) async throws {
        guard let url = URL(string: baseURL + "/follows/following/nickname/\(userNickname)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return try await networkClient.requestVoid(request)
    }
    
    func patchfollows(token: String, userNickname: String) async throws {
        guard let url = URL(string: baseURL + "/follows/nickname/\(userNickname)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }

    func postFCMToken(token: String, fcmToken: FCMToken) async throws {
        guard let url = URL(string: baseURL + "/fcm/token") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "token": fcmToken.token,
            "deviceType": fcmToken.deviceType,
            "deviceId": fcmToken.deviceId
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func deleteFCMToken(token: String, fcmToken: FCMToken) async throws -> FCMDeleted {
        guard let url = URL(string: baseURL + "/fcm-tokens") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: Any] = [
            "token": fcmToken.token,
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: FCMDeleted.self)
    }
    
    func getNotificationList(token: String, count: Int) async throws -> [NotificationItem] {
        guard let url = URL(string: baseURL + "/notification/list?limit=\(count)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: [NotificationItem].self)
    }
    
    func deleteNotificationList(token: String, notiId: Int) async throws {
        guard let url = URL(string: baseURL + "/notification/\(notiId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func deleteWalkLikes(token: String, walkId: Int) async throws {
        guard let url = URL(string: baseURL + "/walk-likes/\(walkId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func postWalkLikes(token: String, walkId: Int) async throws {
        guard let url = URL(string: baseURL + "/walk-likes/\(walkId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func patchCharacterItems(token: String, itemId: Int, isWorn: Bool) async throws {
        guard let url = URL(string: baseURL + "/characters/items/\(itemId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        let body: [String: Any] = [
            "worn": isWorn
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.requestVoid(request)
    }
    
    func getWalkList(token: String) async throws -> [WalkRecord] {
        guard let url = URL(string: baseURL + "/walk/list") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return try await networkClient.request(request, responseType: [WalkRecord].self)
    }
}

// MARK: - Helpers

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

