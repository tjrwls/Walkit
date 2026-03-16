//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/5/25.
//
import Foundation
import CoreLocation

class LocationService : NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    private let manager = CLLocationManager()
    var completionHandler: ((CLLocationCoordinate2D) -> (Void))?
    var failedHandler: (() -> Void)?
    var currentLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        //CLLocationManager의 delegate 설정
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 10
    }
    
    func setCompletionHandler(completion: @escaping ((CLLocationCoordinate2D) -> (Void))) {
        completionHandler = completion
    }
    
    func setFailedHandler(completion: @escaping () -> (Void)) {
        failedHandler = completion
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {}
    
    //위치 정보가 업데이트 될 때 호출되는 delegate 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard location.horizontalAccuracy > 0,
              location.horizontalAccuracy <= 50 else {
            return
        }
        currentLocation = location.coordinate
        completionHandler?(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        failedHandler?()
        print(error)
    }

    func checkLocationPermission() -> Bool? {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways:
            debugPrint("위치 권한: Always")
            return true
            
        case .authorizedWhenInUse:
            debugPrint("위치 권한: WhenInUse")
            manager.requestAlwaysAuthorization()
            return true
            
        case .denied:
            debugPrint("위치 권한: 거부됨")
            return false
            
        case .restricted:
            debugPrint("위치 권한: 제한됨")
            return false
            
        case .notDetermined:
            debugPrint("위치 권한: 아직 요청 안 함")
            manager.requestWhenInUseAuthorization()
            return nil
            
        @unknown default:
            return false
        }
    }
    
    func configureLocationUpdates() {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
            manager.startUpdatingLocation()

        case .authorizedWhenInUse:
            manager.allowsBackgroundLocationUpdates = false
            manager.pausesLocationUpdatesAutomatically = true
            manager.startUpdatingLocation()

        case .denied, .restricted:
            manager.stopUpdatingLocation()

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }


}
    
