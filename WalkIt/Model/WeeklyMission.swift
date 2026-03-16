//
//  Mission.swift
//  WalkIt
//
//  Created by 조석진 on 12/26/25.
//

struct WeeklyMission: Decodable {
    var active: Mission
    var others: [Mission]
}

struct Mission: Decodable {
    var userWeeklyMissionId: Int?
    var missionId: Int
    var title: String
    var category: String
    var type: String
    var status: MissionStatus?
    var rewardPoints: Int
    var assignedConfigJson: String?
    var weekStart: String
    var weekEnd: String
    var completedAt: String?
    var failedAt: String?
}

enum MissionStatus: String, Decodable {
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case fail = "FAILED"
}

enum MissionCategory: String, CaseIterable, Identifiable {
    case findObject = "PHOTO"
    case challenge = "CHALLENGE"
    var id: String { rawValue }
}


enum MissionType: String, CaseIterable, Identifiable {
    case attendance = "CHALLENGE_ATTENDANCE"
    case steps = "CHALLENGE_STEPS"
    var id: String { rawValue }
}
