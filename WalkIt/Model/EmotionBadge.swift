//
//  EmotionBadge.swift
//  WalkIt
//
//  Created by 조석진 on 12/28/25.
//

import Foundation

struct EmotionBadge: Identifiable {
    let id = UUID()
    let emotion: String
    let backgroundColor: String
    let textColor: String
}
