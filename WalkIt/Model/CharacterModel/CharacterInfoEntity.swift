//
//  CharacterInfo.swift
//  WalkIt
//
//  Created by 조석진 on 12/27/25.
//

import RealmSwift
import Foundation

class CharacterInfoEntity: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var userId: Int = 0
    @Persisted var headImageName: String?
    @Persisted var bodyImageName: String?
    @Persisted var feetImageName: String?
    @Persisted var characterImageName: String?
    @Persisted var backgroundImageName: String?
    @Persisted var level: Int = 1
    @Persisted var grade: String = "SEED"
    @Persisted var nickName: String = ""
}
