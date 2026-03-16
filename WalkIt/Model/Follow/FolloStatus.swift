//
//  FolloStatus.swift
//  WalkIt
//
//  Created by 조석진 on 1/12/26.
//


enum FolloStatus: String, Decodable {
    case EMPTY = "EMPTY"
    case PENDING = "PENDING"
    case ACCEPTED = "ACCEPTED"
    case REJECTED = "REJECTED"
    case MYSELF = "MYSELF"
}