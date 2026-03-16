//
//  SearchUsers.swift
//  WalkIt
//
//  Created by 조석진 on 1/6/26.
//

struct SearchUsers: Decodable, Hashable {
    let userId: Int
    let imageName: String
    let nickName: String
    var followStatus: FolloStatus
}


