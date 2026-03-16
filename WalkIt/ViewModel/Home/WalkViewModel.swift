//
//  PedometerViewModel.swift
//  WalkIt
//
//  Created by 조석진 on 12/5/25.
//
import Combine
import UIKit
import CoreLocation
import SwiftUI
import PhotosUI
import KakaoMapsSDK
import RealmSwift
import ImageIO

class WalkViewModel: ObservableObject {
    private var pedometerManager: PedometerManager
    private var realmManager: RealmManager = RealmManager.shared
    private let serverManager = ServerManager.shared
    private let locationService = LocationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: NavigationPath
    @Published var path = NavigationPath()

    // MARK: EmotionBeforeWalkView
    @Published var emotionBeforeWalk: String = ""
    @Published var valueBeforeWalk: Int = 3
    
    // MARK: WalkingView
    @Published var steps: Int = 0
    @Published var distance: Int = 0
    @Published var elapsedTime: Int = 0
    @Published var isRunning = false
//    @Published var headImageName: String = ""
//    @Published var bodyImageName: String = ""
//    @Published var feetImageName: String = ""
//    @Published var characterImageName: String = ""
    @Published var backgroundImageName: String = ""
    let backGroundImageHeight = 812.0
    let backGroundImageWidth = 375.0
    
    // MARK: EmotionAfterWalkView
    @Published var emotionAfterWalk: String = ""
    @Published var valueAfterWalk: Int = 3
    @Published var showingAlertExit: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: RecordTextView
    @Published var selectedItem: PhotosPickerItem?
    @Published var showPhotoPicker = false
    @Published var selectedImage: UIImage? = nil
    @Published var isWalkInImageAlert = false
    @Published var isTextEditor = false
    @Published var showingEditMenu = false
    @Published var note: String = ""
    @Published var showCamera = false

    // MARK: RecordTextView
    var startTime: Int = 0
    var endTime: Int = 0
    var points: [WalkPoint] = []
    @Published var showSavingProgress = false
    @Published var showSavingSuccess = false
    @Published var savedImage: UIImage? = nil
    @Published var weekWalkCount = 1
    @Published var weekGoalCount = 1
    @Published var updateGoalsPercent: Int = 0
    @Published var goalCountPercent: Double = 0
    @Published var showUploadSheet = false
    
    // MARK: BackGround
    var startBackroundTime: Date = Date()
    var endBackroundTime: Date = Date()
    @Published var useDefaultImage = false
    
    
    enum WalkRecordRoute: Hashable {
        case emotionAfterWalkView
        case walkRecordView
        case checkRecordingView
    }
    @Published var walkRootViewIndex: WalkRecordRoute = .emotionAfterWalkView
    @Published var isGoingForward: Bool = true // 다음/이전 방향 구분

    @Published var lottieJson: [String: Any] = [:]
    @Published var isShowSavingView: Bool = false
    
    let emosionsBadge: [EmotionBadge] = [
        EmotionBadge(emotion: "DELIGHTED", backgroundColor: "#FEF7D7", textColor: "#D7A204"),
        EmotionBadge(emotion: "JOYFUL", backgroundColor: "#F3FFF8", textColor: "#2ABB42"),
        EmotionBadge(emotion: "HAPPY", backgroundColor: "#FFF0F1", textColor: "#F76476"),
        EmotionBadge(emotion: "DEPRESSED", backgroundColor: "#E9F2FF", textColor: "#1D7AFC"),
        EmotionBadge(emotion: "TIRED", backgroundColor: "#F6F4FF", textColor: "#6E5DC6"),
        EmotionBadge(emotion: "IRRITATED", backgroundColor: "#FFF0EE", textColor: "#E65C4A")
    ]
    
    // MARK: KakaoMap
    let width = UIScreen.main.bounds.width - 40
    @Published var isMapReady: Bool = false
    weak var kakaoCoordinator: KakaoMapView.KakaoMapCoordinator?

    func captureMapImage() {
        guard let image = kakaoCoordinator?.captureContainerImage() else { return }
        Task { @MainActor in
            self.savedImage = image
            let result = await saveWalk()
            if(result) { self.showSavingSuccess = true }
            self.showSavingProgress = false
        }
    }

    init() {
        self.pedometerManager = PedometerManager.shared
        pedometerManager.$steps
            .receive(on: RunLoop.main)
            .assign(to: \.steps, on: self)
            .store(in: &cancellables)
        pedometerManager.$distance
            .receive(on: RunLoop.main)
            .assign(to: \.distance, on: self)
            .store(in: &cancellables)
    }
    
    func goNext(_ route: HomeRoute) {
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
    
    func walkRecordGoNext() {
        isGoingForward = true
        switch(walkRootViewIndex) {
        case .emotionAfterWalkView:
            walkRootViewIndex = .walkRecordView
            break
        case .walkRecordView:
            walkRootViewIndex = .checkRecordingView
            break
        case .checkRecordingView:
            break
        }
    }
    
    func walkRecordGoPrev() {
        isGoingForward = false
        switch(walkRootViewIndex) {
        case .emotionAfterWalkView:
            break
        case .walkRecordView:
            walkRootViewIndex = .emotionAfterWalkView
            break
        case .checkRecordingView:
            walkRootViewIndex = .walkRecordView
            break
        }
    }

    func reset() {
        steps = 0
        distance = 0
        elapsedTime = 0
        isRunning = true
        
        valueBeforeWalk = 3
        emotionAfterWalk = ""
        valueAfterWalk = 3
        
        showingAlertExit = false
        selectedItem = nil
        showPhotoPicker = false
        selectedImage = nil
        isWalkInImageAlert = false
        isTextEditor = false
        showingEditMenu = false
        showSavingSuccess = false
        savedImage = nil
        note = ""
        startTime = 0
        endTime = 0
        points = []
    }
    
    func startWalk() {
        startTime = Int(Date().timeIntervalSince1970 * 1000)
        pedometerManager.startPedometerUpdates()
        locationService.setCompletionHandler { [weak self] coordinate in
            self?.points.append(WalkPoint(latitude: coordinate.latitude, longitude: coordinate.longitude, timestampMillis: Int(Date().timeIntervalSince1970)))
        }
        locationService.configureLocationUpdates()
    }
    
    func reStartWalk() {
        pedometerManager.startPedometerUpdates()
        locationService.configureLocationUpdates()
    }

    func stopWalk() {
        pedometerManager.stopPedometerUpdates()
        locationService.stopUpdatingLocation()
    }

    func refreshStepHistory() {
        pedometerManager.getStep(startTime: startBackroundTime, endTime: endBackroundTime)
    }
    
    func loadWalkingView() {
        Task {
            let point = locationService.currentLocation
            guard let characterInfo = await getWalkCharacter(latitude: point?.latitude ?? 0.0, longitude: point?.longitude ?? 0.0) else { return }
//            self.headImageName = characterInfo.headImageName?.imageName ?? ""
//            self.bodyImageName = characterInfo.bodyImageName ?? ""
//            self.feetImageName = characterInfo.feetImageName ?? ""
//            self.characterImageName = characterInfo.characterImageName ?? ""
            self.backgroundImageName = characterInfo.backgroundImageName ?? ""
            isRunning = true
        }
        let weekWalk = realmManager.getWalksInWeek(containing: Date())
        weekWalkCount = weekWalk.count + 1
        let targetWalkCount = UserManager.shared.targetWalkCount
        let targetStepCount = UserManager.shared.targetStepCount
        let goalCount = weekWalk.filter{ $0.stepCount >= targetStepCount }.count
        weekGoalCount = goalCount + 1
        if(targetWalkCount != 0 && weekWalkCount > 0) {
            goalCountPercent = min((Double(goalCount) / Double(targetWalkCount)), 1.0)
            if(steps >= targetStepCount && goalCountPercent < 1) {
                updateGoalsPercent = Int(max((Double(goalCount + 1) / Double(targetWalkCount)), 1.0) - goalCountPercent) * 100
            }
        }
        loadCharacter()
    }
    
    func getWalkCharacter(latitude: Double, longitude: Double) async -> CharacterInfo? {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return nil }
        var result: CharacterInfo? = nil
        do {
            result = try await serverManager.getWalkCharacter(token: accessToken, latitude: latitude, longitude: longitude)
            debugPrint("getWalkCharacter: \(result!)")
        } catch {
            useDefaultImage = true
            debugPrint("getWalkCharacter Error")
        }
        return result
    }
    
    func timeString(from seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d : %02d : %02d", h, m, s)
    }
    
    func getWalkRecordEntity() ->WalkRecordEntity {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        let todayString = formatter.string(from: Date())

        let walkRecord = WalkRecordEntity()
        walkRecord.userId = UserManager.shared.userId ?? 0
        walkRecord.walkId = UUID().hashValue
        walkRecord.isSaving = false
        walkRecord.preWalkEmotion = emotionBeforeWalk
        walkRecord.postWalkEmotion = emotionAfterWalk
        walkRecord.note = note
        walkRecord.imageUrl = nil
        walkRecord.startTime = startTime
        walkRecord.endTime = endTime
        walkRecord.totalTime = endTime - startTime
        walkRecord.stepCount = steps
        walkRecord.totalDistance = distance
        walkRecord.createdDate = todayString
        walkRecord.points.append(objectsIn: getWalkRoutes(points: points))
        return walkRecord
    }
    
    func getImage() -> UIImage? {
        if(savedImage == nil) {
            guard let image = kakaoCoordinator?.captureContainerImage() else { return nil }
            return image
        } else {
            return savedImage
        }
    }
    
    func saveWalk() async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            
            let walkRecord = WalkRecord(
                id: UUID().hashValue,
                preWalkEmotion: emotionBeforeWalk,
                postWalkEmotion: emotionAfterWalk,
                note: note,
                imageUrl: nil,
                startTime: startTime,
                endTime: endTime,
                totalTime: endTime - startTime,
                stepCount: steps,
                totalDistance: Double(distance),
                createdDate: "",
                points: points)
            
            let result = try await serverManager.PostWalk(token: accessToken, walkRecord: walkRecord, image: savedImage)
            saveWalkRecord(walkId: result?.id ?? UUID().hashValue, imageURL: result?.imageUrl ?? "")
            debugPrint("saveWalk: \(result!)")
            return true
        } catch {
            debugPrint("saveWalk Error")
            return false
        }
    }
    
    func getWalkRoutes(points: [WalkPoint]) -> [WalkPointEntity] {
        var walkPoints: [WalkPointEntity] = []
        for point in points {
            let walkPointEntity = WalkPointEntity()
            walkPointEntity.latitude = point.latitude ?? 0.0
            walkPointEntity.longitude = point.longitude ?? 0.0
            walkPointEntity.timestamp = point.timestampMillis ?? 0
            walkPoints.append(walkPointEntity)
        }

        return walkPoints
    }
    
    func saveWalkRecord(walkId: Int, imageURL: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        let todayString = formatter.string(from: Date())
        
        let walkRecord = WalkRecordEntity()
        walkRecord.userId = UserManager.shared.userId ?? 0
        walkRecord.walkId = walkId
        walkRecord.isSaving = true
        walkRecord.preWalkEmotion = emotionBeforeWalk
        walkRecord.postWalkEmotion = emotionAfterWalk
        walkRecord.note = note
        walkRecord.imageUrl = imageURL
        walkRecord.startTime = startTime
        walkRecord.endTime = endTime
        walkRecord.totalTime = endTime - startTime
        walkRecord.stepCount = steps
        walkRecord.totalDistance = distance
        walkRecord.createdDate = todayString
        walkRecord.points.append(objectsIn: getWalkRoutes(points: points))
        realmManager.addObject(walkRecord)
    }
    

    func extractExifDate(from data: Data) -> Date? {
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let meta = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
            let exif = meta[kCGImagePropertyExifDictionary] as? [CFString: Any],
            let dateString = exif[kCGImagePropertyExifDateTimeOriginal] as? String
        else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        return formatter.date(from: dateString)
    }

    
    func isWithinWalk(_ date: Date) -> Bool {
        let pickerDate = Int(date.timeIntervalSince1970 * 1000)
        return startTime < pickerDate
    }
    
    func editNote() {
        isTextEditor = true
        showingEditMenu = false
    }

    @MainActor
    func renderImage<V: View>(size: CGSize, @ViewBuilder content: () -> V) -> UIImage? {
        let renderer = ImageRenderer(content: content())
        renderer.scale = 3
        renderer.proposedSize = .init(size)

        return renderer.uiImage
    }
    
    func saveImage() {
        if let uiImage = selectedImage {
            if let image = renderImage(size: CGSize(width: width, height: width), content: {
                CoordinatePathView(coords: points.map {CLLocationCoordinate2D(latitude: $0.latitude ?? 0.0, longitude: $0.longitude ?? 0.0)})
                    .frame(width: width, height: width)
                    .background {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: width)
                    }
            }) {
                savedImage = image
            }
        }
    }
    
    func loadCharacter() {
        Task { @MainActor in
            do {
                let userManager = UserManager.shared
                let baseJsonData = try loadLottieJson(for: userManager.grade)
                var baseJson = try JSONSerialization.jsonObject(with: baseJsonData) as! [String: Any]
                
                if let item = userManager.characterInfo.headImage {
                    let cosmeticItem = CosmeticItem(itemId: 0, imageName: item.imageName ?? "", tag: item.itemTag, position: item.itemPosition ?? .head)
                    baseJson = await changeItem(json: baseJson, item: cosmeticItem)
                }
                
                if let item = userManager.characterInfo.bodyImage {
                    let cosmeticItem = CosmeticItem(itemId: 0, imageName: item.imageName ?? "", tag: item.itemTag, position: item.itemPosition ?? .body)
                    baseJson = await changeItem(json: baseJson, item: cosmeticItem)
                }
                
                if let item = userManager.characterInfo.feetImage {
                    let cosmeticItem = CosmeticItem(itemId: 0, imageName: item.imageName ?? "", tag: item.itemTag, position: item.itemPosition ?? .feet)
                    if(item.imageName == "" || item.imageName == nil) {
                        baseJson = await setDefaultFoot(json: baseJson, grade: userManager.grade)
                    } else {
                        baseJson = await changeItem(json: baseJson, item: cosmeticItem)
                    }
                } else {
                    baseJson = await setDefaultFoot(json: baseJson, grade: userManager.grade)
                }
                
                lottieJson = baseJson
            } catch {
                debugPrint("loadCharacter 실패")
            }
        }
    }
    
    func loadLottieJson(for grade: String) throws -> Data {
        switch(grade) {
        case "SEED":
            guard let url = Bundle.main.url(forResource: "seed", withExtension: "json") else {
                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "seed.json not found in bundle"])
            }
            return try Data(contentsOf: url)
        case "SPROUT":
            guard let url = Bundle.main.url(forResource: "sprout", withExtension: "json") else {
                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "sprout.json not found in bundle"])
            }
            return try Data(contentsOf: url)
        case "TREE":
            guard let url = Bundle.main.url(forResource: "tree", withExtension: "json") else {
                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "tree.json not found in bundle"])
            }
            return try Data(contentsOf: url)
        default:
            guard let url = Bundle.main.url(forResource: "seed", withExtension: "json") else {
                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "seed.json not found in bundle"])
            }
            return try Data(contentsOf: url)
        }
    }
    
    func changeItem(json: [String:Any], item: CosmeticItem) async -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        let imageDownloader: ImageDownloader = ImageDownloader()
        do {
            let base64Image = try await imageDownloader.downloadAsBase64(from: item.imageName)
            let replacejson = try lottieProcessor.replaceAsset(
                in: json,
                assetId: item.getAssetId(),
                with: base64Image
            )
            return replacejson
        } catch {
            debugPrint("changeItem실패")
        }
        return json
    }
 
    func setDefaultFoot(json: [String:Any], grade: String) async -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        var footImage: String = ""
        do {
            if(grade == "SEED") {
                footImage = try assetImageToBase64(named: "DEFAULT_SEED_FEET_IMAGE")
            } else if(grade == "SPROUT") {
                footImage = try assetImageToBase64(named: "DEFAULT_SPROUT_FEET_IMAGE")
            } else if(grade == "TREE") {
                footImage = try assetImageToBase64(named: "DEFAULT_TREE_FEET_IMAGE")
            } else {
                footImage = try assetImageToBase64(named: "DEFAULT_SEED_FEET_IMAGE")
            }
            
            let replacejson = try lottieProcessor.replaceAsset(
                in: json,
                assetId: "foot",
                with: footImage
            )
            return replacejson
        } catch {
            debugPrint("changeItem실패")
        }
        return json
    }
    
    func assetImageToBase64(named imageName: String) throws -> String {
        guard let image = UIImage(
            named: imageName,
            in: Bundle.main,
            compatibleWith: nil
        ) else {
            throw NSError(domain: "AssetImage", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "이미지를 찾을 수 없음: \(imageName)"
            ])
        }
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let renderedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        
        guard let data = renderedImage.pngData() else {
            throw NSError(domain: "AssetImage", code: 1)
        }
        
        return "data:image/png;base64," + data.base64EncodedString()
    }
    
    func requestPhotoPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            // 이미 권한 있음
            completion(true)
            
        case .notDetermined:
            // 권한 요청
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
            
        case .denied, .restricted:
            // 권한 없음
            completion(false)
            
        @unknown default:
            completion(false)
        }
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
