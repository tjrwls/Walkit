//
//  CharacterInfo.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//


struct CharacterInfo: Decodable {
    var headImage: CharacterItem?
    var bodyImage: CharacterItem?
    var feetImage: CharacterItem?
    var characterImageName: String?
    var backgroundImageName: String?
    var level: Int
    var grade: String
    var nickName: String
    var currentGoalSequence: Int
}

struct CharacterItem: Decodable {
    var imageName: String?
    var itemPosition: CharacterPart?
    var itemTag: String?
}
