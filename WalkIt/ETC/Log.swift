//
//  Log.swift
//  WalkIt
//
//  Created by 조석진 on 1/8/26.
//



static func debugPrint(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}
