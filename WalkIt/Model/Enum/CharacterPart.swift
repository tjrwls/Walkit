//
//  CharacterPart.swift
//  WalkIt
//
//  Created by 조석진 on 1/12/26.
//

import Foundation

public enum CharacterPart: String, Codable, CaseIterable, Hashable, Sendable {
    case head = "HEAD"
    case body = "BODY"
    case feet = "FEET"
}

extension CharacterPart {
    // Kotlin enum의 생성자 파라미터(assetId, vararg lottieAssetIds)를 그대로 반영하는 스위프트 헬퍼
    fileprivate var lottieAssetIds: [String] {
        switch self {
        case .head: return ["headtop", "headdecor"]
        case .body: return ["body"]
        case .feet: return ["foot"]
        }
    }

    // Kotlin: fun getLottieAssetId(tags: String? = null): String
    func getLottieAssetId(tags: String?) -> String {
        if let t = tags, !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            switch self {
            case .head:
                if t.range(of: "TOP", options: .caseInsensitive) != nil { return "headtop" }
                if t.range(of: "DECOR", options: .caseInsensitive) != nil { return "headdecor" }
                return lottieAssetIds.first ?? "headtop"
            case .body:
                return lottieAssetIds.first ?? "body"
            case .feet:
                return lottieAssetIds.first ?? "feet"
            }
        } else {
            return lottieAssetIds.first ?? defaultAssetId
        }
    }

    private var defaultAssetId: String {
        switch self {
        case .head: return "headtop"
        case .body: return "body"
        case .feet: return "foot"
        }
    }
}
