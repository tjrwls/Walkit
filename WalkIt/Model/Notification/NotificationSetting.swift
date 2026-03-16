//
//  NotificationSetting.swift
//  WalkIt
//
//  Created by 조석진 on 12/20/25.
//

struct NotificationSetting: Decodable {
    var notificationEnabled: Bool
    var goalNotificationEnabled: Bool
    var missionNotificationEnabled: Bool
    var friendNotificationEnabled: Bool
    var marketingPushEnabled: Bool
}
