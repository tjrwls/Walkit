//
//  UserProfile.swift
//  WalkIt
//
//  Created by 조석진 on 12/20/25.
//


struct Goals: Decodable {
    var targetStepCount: Int
    var targetWalkCount : Int
    var enableUpdateGoal: Bool?
}
