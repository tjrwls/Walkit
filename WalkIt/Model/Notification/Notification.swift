//
//  CharacterInfo.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//


struct NotificationItem: Decodable, Hashable {
    var notificationId: Int
    var type: String
    var title: String
    var body: String
    var senderId: Int?
    var senderNickname: String?
    var targetId: String?
    var createdAt: String
    var read: Bool
}
