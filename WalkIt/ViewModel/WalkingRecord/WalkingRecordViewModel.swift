//
//  WalkIngRecordViewModel.swift
//  Record
//
//  Created by aroot on 12/30/25.
//
import Combine
import Foundation
import RealmSwift
internal import _LocationEssentials
import SwiftUI
import Photos

class WalkingRecordViewModel: ObservableObject {
    enum Period: String, CaseIterable { case month = "월간", week = "주간"}
    private let realmManager = RealmManager.shared
    private let serverManager = ServerManager.shared
    var monthWalkRecords: [WalkRecordEntity] = []
    var weekWalkRecords: [WalkRecordEntity] = []
    @Published var period: Period = .month
    @Published var selectedProfile: Int = 0
    @Published var showingPicker = false
    
    // MARK: NavigationPath
    @Published var path = NavigationPath()

    // MARK: Month
    @Published var currentMonthAnchor: Date = .now
    @Published var selectedDate: Date? = .now
    @Published var monthStampedDays: Set<Int> = []
    @Published var monthMissionStampedDays: Set<Int> = []
    @Published var monthAvgSteps: Int = 0
    @Published var monthWalkTime: Int = 0
    @Published var emotionMonth: String = ""
    @Published var emotionMonthCount: String = ""
    
    // MARK: Week
    @Published var currentWeekAnchor: Date = .now
    @Published var selectedWeekDay: Date? = .now
    @Published var weeklystampedDays: Set<Int> = []
    @Published var weeklyAvgSteps: Int = 0
    @Published var weeklyWalkTime: Int = 0
    @Published var emotionWeek: String = ""
    @Published var emotionWeekCount: String = ""
    
    //MARK: Day
    @Published var selectedDayWalkIdx: Int = 0
    @Published var note: String = ""
    @Published var showingEditMenu = false
    @Published var isTextEditor = false
    var currentDayAnchor: Date = .now
    var currentDay: Date = .now
    var dayWalks: [WalkRecordEntity] = []
    @Published var dayWalk: WalkRecordEntity = WalkRecordEntity()
    @Published var selectedIndex: Int = 0
    @Published var showSaveAlert = false
    
    // MARK: Follow
    @Published var follows: [Follow] = []
//    @Published var follow: [Follow] = []
//    @Published var followCharacterInfo: CharacterInfo? = nil
    @Published var followerWalk : FollowerWalk? = nil
    let backGroundImageHeight = 480.0
    let backGroundImageWidth = 375.0
    var savedNote = ""
    @Published var isDismissAlert: Bool = false
    @Published var isShowingDelete: Bool = false
    @Published var lottieJson: [String: Any] = [:]
    @Published var isShowSavingView = false
    
    
    func goNext(_ route: WalkingRecordRoute) {
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
    
    @MainActor
    func setMothView() {
        monthWalkRecords = realmManager.getWalksMonth(anchor: currentMonthAnchor)
        monthStampedDays = getWalkDays(walkRecords: monthWalkRecords)
        var emotionDic : [String: Int] = [:]
        monthAvgSteps = 0
        monthWalkTime = 0
        for record in monthWalkRecords {
            emotionDic[record.postWalkEmotion ?? "", default: 0] += 1
            monthAvgSteps += record.stepCount
            monthWalkTime += record.totalTime
        }
        monthAvgSteps = monthWalkRecords.isEmpty ? 0 : monthAvgSteps / monthWalkRecords.count
        
        let maxValue = emotionDic.values.max() ?? 0
        self.emotionMonthCount = String(maxValue)
        let maxEmotions = emotionDic.filter { $0.value == maxValue }.keys
        self.emotionMonth = priorityEmotion(emotions: maxEmotions)
        debugPrint("monthWalkRecords \(monthWalkRecords) emotionMax: \(maxEmotions)")
    }
    
    @MainActor
    func getMissionCompletedMonthly() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentMonthAnchor)
        let month = calendar.component(.month, from: currentMonthAnchor)
        monthMissionStampedDays.removeAll()
        do {
            let month = try await serverManager.getMissionCompletedMonthly(token: accessToken, year: year, month: month)
            for day in month {
                let tmp = day.split(separator: "-")
                if(tmp.count == 3) {
                    monthMissionStampedDays.insert(Int(tmp[2]) ?? 0)
                }
            }
        } catch {
            debugPrint("getMissionCompletedMonthly 실패")
        }
    }
    
    func setWeekView() {
        weekWalkRecords = realmManager.getWalksInWeek(containing: currentWeekAnchor)
        weeklystampedDays = getWalkDays(walkRecords: weekWalkRecords)
        var emotionDic : [String: Int] = [:]
        weeklyAvgSteps = 0
        weeklyWalkTime = 0
        
        for record in weekWalkRecords {
            emotionDic[record.postWalkEmotion ?? "", default: 0] += 1
            weeklyAvgSteps += record.stepCount
            weeklyWalkTime += record.totalTime
        }
        weeklyAvgSteps = weekWalkRecords.isEmpty ? 0 : weeklyAvgSteps / weekWalkRecords.count
        
        let maxValue = emotionDic.values.max() ?? 0
        self.emotionWeekCount = String(maxValue)
        let maxEmotions = emotionDic.filter { $0.value == maxValue }.keys
        self.emotionWeek = priorityEmotion(emotions: maxEmotions)

        debugPrint("weekWalkRecords \(weekWalkRecords)")
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
    
    func getWalkDays(walkRecords: [WalkRecordEntity]) -> Set<Int> {
        var days = Set<Int>()
        let calendar = Calendar.current

        for record in walkRecords {
            let ms = Int64(record.startTime)
            let seconds = TimeInterval(ms) / 1000.0
            let date = Date(timeIntervalSince1970: seconds)
            let day = calendar.component(.day, from: date)
            days.insert(day)
        }

        return days
    }
    
    // MARK: - Day
    func getDayView(date: Date) {
        dayWalks = realmManager.getWalkForToday(today: date).sorted { $0.startTime < $1.startTime }
        if(dayWalks.count > 0) {
            dayWalk = dayWalks[0]
            note = dayWalk.note ?? ""
            savedNote = note
        }
    }
    
    func setFollow() async {
        do {
            guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
            self.follows = try await serverManager.getFollows(token: accessToken)
        } catch {
            debugPrint("getFollows 실패")
        }
    }
    
    func getFollowWalk(nickname: String) async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        let latitude = LocationService.shared.currentLocation?.latitude ?? 37.49793238160498
        let longitude = LocationService.shared.currentLocation?.longitude ?? 127.02750263732479
        do {
            followerWalk = try await serverManager.getWalkFollower(token: accessToken, nickname: nickname, latitude: latitude, longitude: longitude)
            loadCharacter()
//            debugPrint("getFollowCharacterInfo: \(followerWalk)")
            return true
        } catch {
            debugPrint("getFollowCharacterInfo 실패")
            return false
        }
    }
    
    func editNote() {
        isTextEditor = true
        showingEditMenu = false
    }
    
    func koreanOrdinalWord(index: Int) -> String {
        let n = index + 1
        guard n >= 1 && n <= 100 else { return "\(n)번째" }
        
        let units = ["", "한", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉"]
        let tens = ["", "열", "스물", "서른", "마흔", "쉰", "예순", "일흔", "여든", "아흔", "백"]
        
        if n == 100 {
            return "백 번째 기록"
        }
        
        let ten = n / 10
        let unit = n % 10
        
        if n <= 10 {
            let firstTen = ["첫", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉", "열"]
            return "\(firstTen[n-1]) 번째 기록"
        }
        
        let tenPart = tens[ten]
        let unitPart = units[unit]
        
        return "\(tenPart)\(unitPart) 번째 기록"
    }
    
    func unixMsToHourMinute(walk: WalkRecordEntity) -> String {
        let startTimeDate = Date(timeIntervalSince1970: TimeInterval(walk.startTime) / 1000)
        let endTimeDate = Date(timeIntervalSince1970: TimeInterval(walk.endTime) / 1000)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: startTimeDate) + " ~ " + formatter.string(from: endTimeDate)
    }
    
    func deleteNote() {
        Task { @MainActor in
            note = ""
            _ = await fetchWalk()
            isTextEditor = false
        }
    }
    
    func deleteWalk() {
        if(dayWalks.count > 1) {
            let tmpWalk = dayWalks.remove(at: selectedIndex)
            monthWalkRecords = []
            
            weekWalkRecords = []
            dayWalk = dayWalks.first!
            realmManager.deleteObject(tmpWalk)
            monthWalkRecords = realmManager.getWalksMonth(anchor: currentMonthAnchor)
            weekWalkRecords = realmManager.getWalksInWeek(containing: currentWeekAnchor)
        } else if(dayWalks.count == 1) {
            let tmpWalk = dayWalks.remove(at: selectedIndex)
            monthWalkRecords = []
            weekWalkRecords = []
            goHome()
            dayWalk = WalkRecordEntity()
            realmManager.deleteObject(tmpWalk)
            monthWalkRecords = realmManager.getWalksMonth(anchor: currentMonthAnchor)
            weekWalkRecords = realmManager.getWalksInWeek(containing: currentWeekAnchor)
        }
    }
    
    func fetchWalk() async -> Bool {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return false }
        do {
            try await serverManager.getPatchWalk(token: accessToken, walkId: dayWalk.walkId, note: note)
            realmManager.updateObject {
                dayWalk.note = note
            }
            savedNote = note
            return true
        } catch {
            debugPrint("saveWalk Error")
            return false
        }
    }
    
    func isChangedData() -> Bool {
        return savedNote != note
    }
    
    func getGrade(grade: String) -> String {
        switch(grade) {
        case "SEED": return "씨앗"
        case "SPROUT": return "새싹"
        case "TREE": return "나무"
        default: return "씨앗"
        }
    }
    
    func deleteFollows(nickname: String) async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.deleteFollows(token: accessToken, nickname: nickname)
        } catch {
            debugPrint("deleteFollows 실패")
        }
    }
    
    func postWalkLikes(walkId: Int) async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.postWalkLikes(token: accessToken, walkId: walkId)
        } catch {
            debugPrint("postWalkLikes 실패")
        }
    }
    
    func deleteWalkLikes(walkId: Int) async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.deleteWalkLikes(token: accessToken, walkId: walkId)
        } catch {
            debugPrint("deleteWalkLikes 실패")
        }
    }
    
    func loadCharacter() {
        Task {
            do {
                let characterDto = followerWalk?.characterDto
                let baseJsonData = try loadLottieJson(for: characterDto?.grade ?? "SEED")
                var baseJson = try JSONSerialization.jsonObject(with: baseJsonData) as! [String: Any]
                if let headItem = characterDto?.headImage {
                    if(headItem.itemTag == "TOP") {
                        if let itemImage = headItem.imageName {
                            baseJson = await changePartItem(json: baseJson, part: "headtop", assaset: itemImage)
                        }
                    } else {
                        if let itemImage = headItem.imageName {
                            baseJson = await changePartItem(json: baseJson, part: "headdecor", assaset: itemImage)
                        }
                    }
                }
                
                if let bodyItem = characterDto?.bodyImage {
                    if let itemImage = bodyItem.imageName {
                        baseJson = await changePartItem(json: baseJson, part: "body", assaset: itemImage)
                    }
                }
                
                if let footItem = characterDto?.feetImage {
                    if let itemImage = footItem.imageName {
                        baseJson = await changePartItem(json: baseJson, part: "foot", assaset: itemImage)
                    }
                } else {
                    baseJson = await setDefaultFoot(json: baseJson, grade: characterDto?.grade ?? "SEED")
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
    func changePartItem(json: [String:Any], part: String, assaset: String) async -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        let imageDownloader: ImageDownloader = ImageDownloader()
        do {
            let base64Image = try await imageDownloader.downloadAsBase64(from: assaset)
            let replacejson = try lottieProcessor.replaceAsset(
                in: json,
                assetId: part,
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

