//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/5/25.
//

import CoreMotion
import Combine

class PedometerManager: ObservableObject {
    static let shared = PedometerManager()
    private let pedometer = CMPedometer()
    @Published var steps: Int = 0
    @Published var distance: Int = 0
    
    func startPedometerUpdates() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        
        pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.steps = Int(truncating: pedometerData.numberOfSteps)
                if let dist = pedometerData.distance {
                    self?.distance = dist.intValue
                } else {
                    self?.distance = 0
                }
            }
        }
    }
    
    func stopPedometerUpdates() {
        pedometer.stopUpdates()
    }
    
    func getStep(startTime: Date, endTime: Date) {
        pedometer.queryPedometerData(from: startTime, to: endTime) { data, error in
            if let error = error {
                debugPrint("An error occurred while querying pedometer data: \(error.localizedDescription)")
            } else if let data = data {
                self.steps += data.numberOfSteps.intValue
                self.distance += data.distance?.intValue ?? 0
            }
        }
    }
    
    func checkMotionPermission() -> Bool {
        let motionStatus = CMPedometer.authorizationStatus()
        switch motionStatus {
        case .authorized:
            debugPrint("활동 권한: 허용됨")
            return true
            
        case .denied:
            debugPrint("활동 권한: 거부됨")
            return false
            
        case .restricted:
            debugPrint("활동 권한: 제한됨")
            return false

        case .notDetermined:
            debugPrint("활동 권한: 아직 요청 안 함")
            pedometer.queryPedometerData(from: Date(), to: Date()) { _, _ in }
            return false
            
        @unknown default:
            return false
        }
    }
}
