//
//  MaPageViewModel.swift
//  WalkIt
//
//  Created by 조석진 on 12/22/25.
//
import Combine
import Foundation
import SwiftUI

class MyPageViewModel: ObservableObject {
    private let realmManager = RealmManager.shared
    private let serverManager = ServerManager.shared
    @Published var toalSteps: Int = 0
    @Published var totalWalkHours: Int = 0
    @Published var deleteUserAlert = false
    @Published var path = NavigationPath()

    
    func getWalkSummary() {
        let allWalk = realmManager.getWalkAll()
        toalSteps = 0
        totalWalkHours = 0
        
        allWalk.forEach { walk in
            toalSteps += walk.stepCount
            totalWalkHours += walk.totalTime
        }
    }
    
    func goNext(_ route: MyPageRoute) {
        path.append(route)
    }

    func dismiss() {
        if(!path.isEmpty) {
            path.removeLast()
        }
    }
    
    func goHome() {
        path = NavigationPath()
    }
}
