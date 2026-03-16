//
//  Mission.swift
//  WalkIt
//
//  Created by 조석진 on 12/26/25.
//

struct FollowerWalk: Decodable {
    var characterDto: CharacterInfo
    var walkProgressPercentage: String
    var walkId: Int
    var createdDate: String
    var stepCount: Int
    var totalDistance: Double
    var totalTime: Int
    var likeCount : Int
    var liked: Bool
}
