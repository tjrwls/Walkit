//
//  ItemPart.swift
//  WalkIt
//
//  Created by 조석진 on 1/12/26.
//


enum ItemPart: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case head = "HEAD"
    case body = "BODY"
    case feet = "FEET"
    var id: String { rawValue }
}
