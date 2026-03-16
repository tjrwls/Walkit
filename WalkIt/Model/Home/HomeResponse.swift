//
//  HomeResponse.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//

struct HomeResponse: Decodable {
    let characterDto: CharacterInfo?
    let walkProgressPercentage: String?
    let todaySteps: Int?
    let weeklyMissionDto: Mission?
    let walkResponseDto: [WalkRecord]?
    let weather: String?
    let temperature: Double?
}
