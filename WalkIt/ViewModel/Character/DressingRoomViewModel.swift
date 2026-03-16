//
//  AlimManagerViewModel 2.swift
//  WalkIt
//
//  Created by 조석진 on 1/5/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class DressingRoomViewModel: ObservableObject {
    let userManager = UserManager.shared
    let serverManager = ServerManager.shared
    @Published var items: [CosmeticItem] = []
    @Published var character: CharacterInfo = CharacterInfo(level: 1, grade: "SEED", nickName: "", currentGoalSequence: 0)
    @Published var lottieJson: [String: Any] = [:]
    @Published var point: Int = 0
    @Published var isShowOwnedItem: Bool = false
    @Published var isShowBuy: Bool = false
    @Published var isShowInfo: Bool = false
    @Published var sumPoint: Int = 0
    @Published var canBuyItem: Bool = false
    @Published var showSaveAlert: Bool = false
    
    @Published var headItem: CosmeticItem? = nil
    @Published var bodyItem: CosmeticItem? = nil
    @Published var feetItem: CosmeticItem? = nil
    @Published var buyItems: [CosmeticItem] = []
    @Published var selectedItemPart: ItemPart? = nil

    @Published var showBuyToast: Bool = false
    @Published var showSaveToast: Bool = false
    
    var sumPoints: Int { buyItems.reduce(0) { $0 + $1.point } }
    var canBuy: Bool { sumPoints <= point }
    var getBuyItems: [CosmeticItem] {
        [headItem, bodyItem, feetItem].compactMap{ $0 } 
    }
    let backGroundImageHeight = 480.0
    let backGroundImageWidth = 375.0
    
    // 변경된 사항이 있는지 확인용
    var wornHeadItem: CosmeticItem? = nil
    var wornBodyItem: CosmeticItem? = nil
    var wornFeetItem: CosmeticItem? = nil
    
    var didLoad = false
    func loadView() {
        Task {
            await fetchItems()
            loadCharacter()
            debugPrint("lottieJson: \(lottieJson)")
            didLoad = true
        }
    }
    
    func loadCharacter() {
        character.level = userManager.level
        character.grade = userManager.grade
        character.characterImageName = userManager.characterInfo.characterImageName
        character.backgroundImageName = userManager.characterInfo.backgroundImageName
        character.headImage = userManager.characterInfo.headImage
        character.bodyImage = userManager.characterInfo.bodyImage
        character.feetImage = userManager.characterInfo.feetImage
        Task { @MainActor in
            do {
                let baseJsonData = try loadLottieJson(for: character.grade)
                var baseJson = try JSONSerialization.jsonObject(with: baseJsonData) as! [String: Any]

                for wornItem in items.filter({ $0.worn == true }) {
                    if(wornItem.getAssetId() == "headtop" || wornItem.getAssetId() == "headdecor") {
                        baseJson = await changeItem(json: baseJson, item: wornItem)
                        headItem = wornItem
                        wornHeadItem = headItem
                    } else if(wornItem.getAssetId() == "body") {
                        baseJson = await changeItem(json: baseJson, item: wornItem)
                        bodyItem = wornItem
                        wornBodyItem = bodyItem
                    } else if(wornItem.getAssetId() == "foot") {
                        baseJson = await changeItem(json: baseJson, item: wornItem)
                        feetItem = wornItem
                        wornFeetItem = feetItem
                    }
                }
                
                if(feetItem == nil) {
                    baseJson = await setDefaultFoot(json: baseJson, grade: userManager.grade)
                }
                
                lottieJson = baseJson
            } catch {
                debugPrint("loadCharacter 실패")
            }
        }
    }
    
    func fetchItems() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else {
            items = []
            return
        }
        do {
            let fetched = try await serverManager.getItems(token: accessToken)
            items = fetched
            debugPrint("getItems: \(items)")
        } catch {
            debugPrint("getItems 실패: \(error)")
            items = []
        }
    }
    
    func selecItem(item: CosmeticItem) {
        switch(item.position) {
        case .head:
            if(headItem == item) {
                lottieJson = removeItem(json: lottieJson, item: headItem ?? item)
                headItem = nil
            } else {
                if(headItem?.tag != item.tag) {
                    let tempJson = removeItem(json: lottieJson, item: headItem ?? item)
                    headItem = item
                    Task { @MainActor in
                        lottieJson = await changeItem(json: tempJson, item: headItem ?? item)
                    }
                } else {
                    headItem = item
                    Task { @MainActor in
                        lottieJson = await changeItem(json: lottieJson, item: headItem ?? item)
                    }
                }
            }
            break
        case .body:
            if(bodyItem == item) {
                lottieJson = removeItem(json: lottieJson, item: bodyItem ?? item)
                bodyItem = nil
            } else {
                bodyItem = item
                Task { @MainActor in
                    lottieJson = await changeItem(json: lottieJson, item: bodyItem ?? item)
                }
            }
            break
        case .feet:
            if(feetItem == item) {
                let tmpJson = removeItem(json: lottieJson, item: feetItem ?? item)
                Task { @MainActor in
                    lottieJson = await setDefaultFoot(json: tmpJson, grade: character.grade)
                }
                feetItem = nil
            } else {
                feetItem = item
                Task { @MainActor in
                    lottieJson = await changeItem(json: lottieJson, item: feetItem ?? item)
                }
            }
            break
        }
    }
    
    func getPoint() async {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            let point = try await serverManager.getPoint(token: accessToken)
            self.point = point.point
        } catch {
            debugPrint("getPoint 실패")
        }
    }
}

extension DressingRoomViewModel {
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
    
    func downloadDefaultImages(for character: CharacterData, downloader: ImageDownloader) async throws -> [String: String] {
        var result: [String: String] = [:]

        if let head = character.headImageUrl {
            let assetId = CharacterPart.head.getLottieAssetId(tags: nil)
            result[assetId] = try await downloader.downloadAsBase64(from: head)
        }
        if let body = character.bodyImageUrl {
            let assetId = CharacterPart.body.getLottieAssetId(tags: nil)
            result[assetId] = try await downloader.downloadAsBase64(from: body)
        }
        if let feet = character.feetImageUrl {
            let assetId = CharacterPart.feet.getLottieAssetId(tags: nil)
            result[assetId] = try await downloader.downloadAsBase64(from: feet)
        }
        return result
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
    
    func removeItem(json: [String:Any], item: CosmeticItem) -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        let replacejson = lottieProcessor.clearAssetImage(in: json, assetId: item.getAssetId())
        return replacejson
    }
    
    func removeAllItem(json: [String:Any]) async -> [String:Any] {
        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
        let replacejson = lottieProcessor.clearAllAssetImages(in: json)
        headItem = nil
        bodyItem = nil
        feetItem = nil
        return await setDefaultFoot(json: replacejson, grade: character.grade)
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
            in: Bundle.main,   // ⭐️ 중요
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

extension DressingRoomViewModel {
    func categoryStyle(for part: CharacterPart) -> ItemCategoryStyle {
        switch part {
        case .head:
            return ItemCategoryStyle(
                text: "헤어",
                background: Color("CustomLightPink3"),
                foreground: Color("CustomPink2")
            )
        case .body:
            return ItemCategoryStyle(
                text: "목도리",
                background: Color("CustomPurple3"),
                foreground: Color("CustomPurple")
            )
        case .feet:
            return ItemCategoryStyle(
                text: "신발",
                background: Color("CustomBlue4"),
                foreground: Color("CustomBlue2")
            )
        }
    }
    
    func getGrade(grade: String) -> String {
        switch(grade) {
        case "SEED": return "씨앗"
        case "SPROUT": return "새싹"
        case "TREE": return "나무"
        default: return "씨앗"
        }
    }
    
    func saveItem() async {
        let saveItems: [CosmeticItem] = [headItem, bodyItem, feetItem]
            .compactMap{$0}
            .filter{ $0.owned == false }
        
        if(saveItems.isEmpty) {
            guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
            do {
                for item in items.filter({ $0.worn == true && !saveItems.contains($0)}) {
                    print("worn: false, item: \(item)")
                    try await serverManager.patchCharacterItems(token: accessToken, itemId: item.itemId, isWorn: false)
                }
                
                for item in getBuyItems {
                    print("worn: true, item: \(item)")
                    try await serverManager.patchCharacterItems(token: accessToken, itemId: item.itemId, isWorn: true)
                }
                
                showSaveToast = true
                
                await fetchItems()
                
                for wornItem in items.filter({ $0.worn == true }) {
                    if(wornItem.getAssetId() == "headtop" || wornItem.getAssetId() == "headdecor") {
                        headItem = wornItem
                    } else if(wornItem.getAssetId() == "body") {
                        bodyItem = wornItem
                    } else if(wornItem.getAssetId() == "foot") {
                        feetItem = wornItem
                    }
                }
                
                wornHeadItem = headItem
                wornBodyItem = bodyItem
                wornFeetItem = feetItem
                
                saveUserManagerCharacter()
            } catch {
                debugPrint("postItems 실패")
            }
        } else {
            buyItems = [headItem, bodyItem, feetItem].compactMap{$0}.filter { $0.owned == false }
            canBuyItem = (items.reduce(0) { $0 + $1.point} <= point)
            isShowBuy = true
        }
    }
    
    func buyItems() async {
        let items: [CosmeticItem] = [headItem, bodyItem, feetItem]
            .compactMap{$0}
            .filter{ $0.owned == false }

        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        do {
            try await serverManager.postItems(token: accessToken, items: items)
            
            let saveItems: [CosmeticItem] = [headItem, bodyItem, feetItem]
                .compactMap{$0}
                .filter{ $0.owned == false }
            
            for item in items.filter({ $0.worn == true && !saveItems.contains($0)}) {
                print("worn: false, item: \(item)")
                try await serverManager.patchCharacterItems(token: accessToken, itemId: item.itemId, isWorn: false)
            }
            
            for item in getBuyItems {
                print("worn: true, item: \(item)")
                try await serverManager.patchCharacterItems(token: accessToken, itemId: item.itemId, isWorn: true)
            }
            
            wornHeadItem = headItem
            wornBodyItem = bodyItem
            wornFeetItem = feetItem
            
            saveUserManagerCharacter()
            await fetchItems()
            showBuyToast = true
        } catch {
            debugPrint("postItems 실패")
        }
    }
    
    func isWearingItem(item: CosmeticItem) -> Bool {
        return (headItem == item) || (bodyItem == item) || (feetItem == item)
    }
    
    func isChangedItem() -> Bool {
        if(wornHeadItem != headItem) { return true }
        if(wornBodyItem != bodyItem) { return true }
        if(wornFeetItem != feetItem) { return true }
        return false
    }
    
    func getItemPart(itemPart: ItemPart) -> String {
        switch(itemPart) {
        case .head: return "헤어"
        case .body: return "목도리"
        case .feet: return "신발"
        }
    }
    
    func saveUserManagerCharacter() {
        userManager.characterInfo.headImage?.imageName = headItem?.imageName
        userManager.characterInfo.headImage?.itemTag = headItem?.tag
        userManager.characterInfo.headImage?.itemPosition = headItem?.position
        
        userManager.characterInfo.bodyImage?.imageName = bodyItem?.imageName
        userManager.characterInfo.bodyImage?.itemTag = bodyItem?.tag
        userManager.characterInfo.bodyImage?.itemPosition = bodyItem?.position
        
        userManager.characterInfo.feetImage?.imageName = feetItem?.imageName
        userManager.characterInfo.feetImage?.itemTag = feetItem?.tag
        userManager.characterInfo.feetImage?.itemPosition = feetItem?.position
    }
}

struct ItemCategoryStyle {
    let text: String
    let background: Color
    let foreground: Color
}
