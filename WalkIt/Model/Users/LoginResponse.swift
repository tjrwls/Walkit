//
//  LoginResponse.swift
//  WalkIt
//
//  Created by 조석진 on 12/20/25.
//


struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let registered: Bool
}
