//
//  UserProfile.swift
//  WalkIt
//
//  Created by 조석진 on 12/20/25.
//


struct Follow: Decodable, Hashable {
    var userId : Int
    var nickname: String
    var imageName : String
}
