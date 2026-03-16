//
//  Character.swift
//  WalkIt
//
//  Created by 조석진 on 1/6/26.
//

import Foundation

public struct CharacterData: Codable, Hashable, Sendable {
    public let id: String
    public let grade: Int
    public let headImageUrl: String?
    public let bodyImageUrl: String?
    public let feetImageUrl: String?  

    public init(
        id: String,
        grade: Int,
        headImageUrl: String?,
        bodyImageUrl: String?,
        feetImageUrl: String?
    ) {
        self.id = id
        self.grade = grade
        self.headImageUrl = headImageUrl
        self.bodyImageUrl = bodyImageUrl
        self.feetImageUrl = feetImageUrl
    }
}

