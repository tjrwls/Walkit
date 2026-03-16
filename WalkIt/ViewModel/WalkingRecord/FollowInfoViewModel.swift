////
////  WalkIngRecordViewModel.swift
////  Record
////
////  Created by aroot on 12/30/25.
////
//
//import Foundation
//import Combine
//import UIKit
//
//class FollowInfoViewModel: ObservableObject {
//    @Published var lottieJson: [String: Any] = [:]
//
//    let followWalkSummary: UserWalkSummary? = nil
//    let backGroundImageHeight = 480.0
//    let backGroundImageWidth = 375.0
//    var calcImageheghit : Double {
//        return backGroundImageHeight / backGroundImageWidth
//    }
// 
//    func loadCharacter() {
//        Task {
//            do {
//                let characterDto = followWalkSummary?.responseCharacterDto
//                let baseJsonData = try loadLottieJson(for: characterDto?.grade ?? "SEED")
//                var baseJson = try JSONSerialization.jsonObject(with: baseJsonData) as! [String: Any]
//                if let headItem = characterDto?.headImage {
//                    if(headItem.itemTag == "TOP") {
//                        if let itemImage = headItem.imageName {
//                            baseJson = await changePartItem(json: baseJson, part: "headtop", assaset: itemImage)
//                        }
//                    } else {
//                        if let itemImage = headItem.imageName {
//                            baseJson = await changePartItem(json: baseJson, part: "headdecor", assaset: itemImage)
//                        }
//                    }
//                }
//                
//                if let bodyItem = characterDto?.bodyImage {
//                    if let itemImage = bodyItem.imageName {
//                        baseJson = await changePartItem(json: baseJson, part: "body", assaset: itemImage)
//                    }
//                }
//                
//                if let footItem = characterDto?.feetImage {
//                    if let itemImage = footItem.imageName {
//                        baseJson = await changePartItem(json: baseJson, part: "foot", assaset: itemImage)
//                    }
//                } else {
//                    baseJson = await setDefaultFoot(json: baseJson, grade: characterDto?.grade ?? "SEED")
//                }
//                
//                lottieJson = baseJson
//            } catch {
//                debugPrint("loadCharacter 실패")
//            }
//        }
//    }
//    
//    func loadLottieJson(for grade: String) throws -> Data {
//        switch(grade) {
//        case "SEED":
//            guard let url = Bundle.main.url(forResource: "seed", withExtension: "json") else {
//                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "seed.json not found in bundle"])
//            }
//            return try Data(contentsOf: url)
//        case "SPROUT":
//            guard let url = Bundle.main.url(forResource: "sprout", withExtension: "json") else {
//                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "sprout.json not found in bundle"])
//            }
//            return try Data(contentsOf: url)
//        case "TREE":
//            guard let url = Bundle.main.url(forResource: "tree", withExtension: "json") else {
//                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "tree.json not found in bundle"])
//            }
//            return try Data(contentsOf: url)
//        default:
//            guard let url = Bundle.main.url(forResource: "seed", withExtension: "json") else {
//                throw NSError(domain: "Lottie", code: 1, userInfo: [NSLocalizedDescriptionKey: "seed.json not found in bundle"])
//            }
//            return try Data(contentsOf: url)
//        }
//    }
//    func changePartItem(json: [String:Any], part: String, assaset: String) async -> [String:Any] {
//        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
//        let imageDownloader: ImageDownloader = ImageDownloader()
//        do {
//            let base64Image = try await imageDownloader.downloadAsBase64(from: assaset)
//            let replacejson = try lottieProcessor.replaceAsset(
//                in: json,
//                assetId: part,
//                with: base64Image
//            )
//            return replacejson
//        } catch {
//            debugPrint("changeItem실패")
//        }
//        return json
//    }
//    
//    func setDefaultFoot(json: [String:Any], grade: String) async -> [String:Any] {
//        let lottieProcessor: LottieImageProcessor = LottieImageProcessor()
//        var footImage: String = ""
//        do {
//            if(grade == "SEED") {
//                footImage = try assetImageToBase64(named: "DEFAULT_SEED_FEET_IMAGE")
//            } else if(grade == "SPROUT") {
//                footImage = try assetImageToBase64(named: "DEFAULT_SPROUT_FEET_IMAGE")
//            } else if(grade == "TREE") {
//                footImage = try assetImageToBase64(named: "DEFAULT_TREE_FEET_IMAGE")
//            } else {
//                footImage = try assetImageToBase64(named: "DEFAULT_SEED_FEET_IMAGE")
//            }
//            
//            let replacejson = try lottieProcessor.replaceAsset(
//                in: json,
//                assetId: "foot",
//                with: footImage
//            )
//            return replacejson
//        } catch {
//            debugPrint("changeItem실패")
//        }
//        return json
//    }
//    
//    
//    func assetImageToBase64(named imageName: String) throws -> String {
//        guard let image = UIImage(
//            named: imageName,
//            in: Bundle.main,   // ⭐️ 중요
//            compatibleWith: nil
//        ) else {
//            throw NSError(domain: "AssetImage", code: 0, userInfo: [
//                NSLocalizedDescriptionKey: "이미지를 찾을 수 없음: \(imageName)"
//            ])
//        }
//        
//        let renderer = UIGraphicsImageRenderer(size: image.size)
//        let renderedImage = renderer.image { _ in
//            image.draw(in: CGRect(origin: .zero, size: image.size))
//        }
//        
//        guard let data = renderedImage.pngData() else {
//            throw NSError(domain: "AssetImage", code: 1)
//        }
//        
//        return "data:image/png;base64," + data.base64EncodedString()
//    }
//
//    
//    func getGrade(grade: String) -> String {
//        switch(grade) {
//        case "SEED": return "씨앗"
//        case "SPROUT": return "새싹"
//        case "TREE": return "나무"
//        default: return "씨앗"
//        }
//    }
//}
//
