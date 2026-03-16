//
//  WalkResponse.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//

struct WalkRecord: Decodable {
    let id: Int?
    let preWalkEmotion: String?
    let postWalkEmotion: String?
    let note: String?
    let imageUrl: String?
    let startTime: Int?
    let endTime: Int?
    let totalTime: Int?
    let stepCount: Int?
    let totalDistance: Double?
    let createdDate: String?
    let points: [WalkPoint]?
}
