//
//  UserProfile.swift
//  WalkIt
//
//  Created by 조석진 on 12/20/25.
//


struct UserProfile: Decodable {
    let userId: Int
    let imageName: String?
    let nickname: String?
    let birthDate: String?
}
