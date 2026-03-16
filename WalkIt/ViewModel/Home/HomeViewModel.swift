import SwiftUI
import Combine
import CoreLocation

class HomeViewModel: ObservableObject {
    let serverManager = ServerManager.shared
    let locationService = LocationService.shared
    let realmManager = RealmManager.shared
    @Published var todaySteps: Int = 0
    @Published var walkProgressPercentage: String = ""
    
    // MARK: 캐릭터
    @Published var backgroundImageName: String = ""
    @Published var level: Int = 1
    @Published var grade: String = ""
    @Published var nickName: String = ""
    let backGroundImageHeight = 480.0
    let backGroundImageWidth = 375.0
    
    // MARK: 날씨
    @Published var tempC: String = "-"
    @Published var sky: String = "SUNNY"
    
    // MARK: 미션
    @Published var mission: Mission?
    @Published var recentlyWalk: [String] = []
    @Published var weekEmotion: [String] = []
    @Published var maxEmotion: String = ""
    @Published var emotionCount: String = ""
    @Published var isAgreeLocationService = true
    @Published var useDefaultImage = false
    @Published var lottieJson: [String: Any] = [:]

    var isLoaded = false
    
    func loadView() {
        guard !isLoaded else { return }
        Task {
            let homeResponse = await self.homeResponse(
                latitude: locationService.currentLocation?.latitude ?? 37.49793238160498,
                longitude: locationService.currentLocation?.longitude ?? 127.02750263732479
            )
            
            guard let homeResponse = homeResponse else { return }
            self.walkProgressPercentage = homeResponse.walkProgressPercentage ?? "0"
            
            if let characterDto = homeResponse.characterDto {
                self.backgroundImageName = characterDto.backgroundImageName ?? ""
                self.level = characterDto.level
                self.grade = characterDto.grade
                self.nickName = characterDto.nickName
                let userManager = UserManager.shared
                userManager.level = self.level
                userManager.grade = self.grade
                userManager.characterInfo = characterDto
                loadCharacter()
            }
            
            self.tempC = String(Int(homeResponse.temperature?.rounded() ?? 0))
            self.sky = homeResponse.weather ?? "SUNNY"
            
            if let weeklyMissionDto = homeResponse.weeklyMissionDto {
                self.mission = weeklyMissionDto
            }
            self.isLoaded = true
        }
    }
    
    func loadViewWalkData() {
        recentlyWalk = realmManager.getRecently7days()
        debugPrint("recentlyWalk: \(recentlyWalk.map{realmManager.getWalk(by: $0)})")
        weekEmotion = recentlyWalk.map{ realmManager.getWalk(by: $0)?.postWalkEmotion ?? ""}
        todaySteps = realmManager.getWalkForToday(today: Date()).reduce(0) { result, walk in
            result + walk.stepCount
        }
        getWeeklyEmotion()
        loadCharacter()
    }
    
    func homeResponse(latitude: Double, longitude: Double) async -> HomeResponse? {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return nil }
        var result: HomeResponse? = nil
        do {
            result = try await serverManager.getHomeResponse(token: accessToken, latitude: latitude, longitude: longitude)
            debugPrint("homeResponse: \(result!)")
        } catch {
            self.useDefaultImage = true
            debugPrint("homeResponse 실패")
        }
        return result
    }
    
    func getGrade(grade: String) -> String {
        switch(grade) {
        case "SEED": return "씨앗"
        case "SPROUT": return "새싹"
        case "TREE": return "나무"
        default: return "씨앗"
        }
    }
    
    func getWeeklyEmotion() {
        var emotionDic: [String : Int] = [:]
        for emotion in weekEmotion {
            emotionDic[emotion, default: 0] += 1
        }
        
        let maxValue = emotionDic.values.max() ?? 0
        self.emotionCount = String(maxValue)
        let maxEmotions = emotionDic.filter { $0.value == maxValue }.keys
        self.maxEmotion = priorityEmotion(emotions: maxEmotions)
    }
    
    func priorityEmotion(emotions: Dictionary<String, Int>.Keys) -> String {
        if(emotions.contains("DELIGHTED")) { return "DELIGHTED"}
        if(emotions.contains("JOYFUL")) { return "JOYFUL"}
        if(emotions.contains("HAPPY")) { return "HAPPY"}
        if(emotions.contains("DEPRESSED")) { return "DEPRESSED"}
        if(emotions.contains("TIRED")) { return "TIRED"}
        if(emotions.contains("IRRITATED")) { return "IRRITATED"}
        return ""
    }
 
    func postVerifyMission(missionId: Int) async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            let result = try await serverManager.postVerifyMission(token: accessToken, userwmId: missionId)
            mission = result
            return true
        } catch {
            return false
        }
    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func loadCharacter() {
        Task { @MainActor in
            do {
                let userManager = UserManager.shared
                let baseJsonData = try loadLottieJson(for: grade)
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
}
