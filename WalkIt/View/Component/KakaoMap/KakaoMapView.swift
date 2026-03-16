import SwiftUI
import KakaoMapsSDK
import Combine
import CoreLocation

struct KakaoMapView: UIViewRepresentable {
    var walkRoutes: [WalkPointEntity]
    var onCoordinatorReady: ((KakaoMapCoordinator) -> Void)? = nil

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer(frame: .zero)
        context.coordinator.createController(view)
        onCoordinatorReady?(context.coordinator)
        return view
    }

    func makeCoordinator() -> KakaoMapCoordinator {
        var mapPoins: [MapPoint] = []
        var coordinate = CLLocationCoordinate2D(
            latitude: LocationService.shared.currentLocation?.latitude ?? 37.49793238160498,
            longitude: LocationService.shared.currentLocation?.longitude ?? 127.02750263732479
        )
        
        if(walkRoutes.count > 0) {
            mapPoins = self.walkRoutes.sorted { $0.timestamp < $1.timestamp }.map { MapPoint(longitude: $0.longitude, latitude: $0.latitude) }
            coordinate = CLLocationCoordinate2D(
                latitude: walkRoutes.first?.latitude ?? 37.49793238160498,
                longitude: walkRoutes.first?.longitude ?? 127.02750263732479
            )

        } else {
            mapPoins = [MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)]
        }
        
        return KakaoMapCoordinator(coordinate: coordinate, walkRoutes: mapPoins)
    }

    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let controller = context.coordinator.controller else { return }

            if controller.isEnginePrepared == false { controller.prepareEngine() }

            if controller.isEngineActive == false { controller.activateEngine() }
        }
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {}


    final class KakaoMapCoordinator: NSObject, MapControllerDelegate {
        let coordinate: CLLocationCoordinate2D
        var controller: KMController?
        var container: KMViewContainer?
        let mapPoints: [MapPoint]
        var didFitBounds = false

        init(coordinate: CLLocationCoordinate2D, walkRoutes: [MapPoint]) {
            self.coordinate = coordinate
            self.mapPoints = walkRoutes
        }

        func createController(_ view: KMViewContainer) {
            container = view
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }

        func addViews() {
            let defaultPosition: MapPoint = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
            controller?.addView(mapviewInfo)
        }

        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            guard let view = controller?.getView("mapview") else { return }
            view.viewRect = container!.bounds
            view.setGestureEnable(type: .pan, enable: false)
            view.setGestureEnable(type: .zoom, enable: false)
            view.setGestureEnable(type: .rotate, enable: false)
            view.setGestureEnable(type: .tilt, enable: false)

            if(!mapPoints.isEmpty) {
                createRoutelineStyleSet()
                createRouteline()
                updateCamera()
            }
        }


        func authenticationSucceeded() {
            debugPrint("인증 성공")
        }

        func authenticationFailed(_ errorCode: Int, desc: String) {
            debugPrint("error code: \(errorCode)")
            debugPrint("desc: \(desc)")
            switch errorCode {
            case 400:
                debugPrint("지도 종료(API인증 파라미터 오류)")
                break;
            case 401:
                debugPrint("지도 종료(API인증 키 오류)")
                break;
            case 403:
                debugPrint("지도 종료(API인증 권한 오류)")
                break;
            case 429:
                debugPrint("지도 종료(API 사용쿼터 초과)")
                break;
            case 499:
                debugPrint("지도 종료(네트워크 오류) 5초 후 재시도..")
                // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
                break;
            default:
                break;
            }
        }

        func createRoutelineStyleSet() {
            guard let mapView = controller?.getView("mapview") as? KakaoMap else { return }
            let manager = mapView.getRouteManager()
            _ = manager.addRouteLayer(layerID: "routeLayer", zOrder: 10001)

            let routeStyle = RouteStyle(styles: [PerLevelRouteStyle(width: 4, color: UIColor(Color("CustomBlue5")), level: 0)])
            let styleSet = RouteStyleSet(styleID: "routeStyle", styles: [routeStyle])
            manager.addRouteStyleSet(styleSet)
        }

        func createRouteline() {
            guard let mapView = controller?.getView("mapview") as? KakaoMap else { return }
            let manager = mapView.getRouteManager()
            let layer = manager.addRouteLayer(layerID: "routeLayer", zOrder: 0)
            let options = RouteOptions(routeID: "routes", styleID: "routeStyle", zOrder: 0)

            var segments: [RouteSegment] = [RouteSegment]()
            let seg = RouteSegment(points: mapPoints, styleIndex: 0)
            segments.append(seg)
            options.segments = segments

            let route = layer?.addRoute(option: options)
            route?.show()
        }

        func updateCamera() {
            guard let mapView = controller?.getView("mapview") as? KakaoMap else { return }
            let areaRect = AreaRect(points: mapPoints)
            let cameraUpdate = CameraUpdate.make(area: areaRect, levelLimit: 18)
            mapView.moveCamera(cameraUpdate)
        }

        func captureContainerImage() -> UIImage? {
            guard let view = container else { return nil }

            let format = UIGraphicsImageRendererFormat()
            format.scale = 3
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(size: view.bounds.size, format: format)

            return renderer.image { ctx in
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
        }
    }
}
