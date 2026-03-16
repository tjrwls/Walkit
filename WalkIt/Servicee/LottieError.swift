//
//  LottieError.swift
//  WalkIt
//
//  Created by 조석진 on 1/6/26.
//

import Foundation

enum LottieError: Error {
    case invalidImageFormat
    case invalidURL
    case invalidResponse
}

class LottieImageProcessor {
    func downloadAndConvertImage(url: String) async throws -> String {
        let imageData = try await downloadImage(from: url)
        guard isValidPNG(imageData) else {
            throw LottieError.invalidImageFormat
        }

        return "data:image/png;base64," + imageData.base64EncodedString()
    }

    func replaceAsset(in json: [String: Any], assetId: String, with base64Image: String) throws -> [String: Any] {
        var modifiedJson = json

        guard var assets = modifiedJson["assets"] as? [[String: Any]] else {
            return modifiedJson
        }

        for (index, var asset) in assets.enumerated() {
            guard asset["id"] as? String == assetId else { continue }

            if let _ = asset["p"] as? String {
                asset["p"] = base64Image
                assets[index] = asset
                break
            } else if var imagePaths = asset["p"] as? [Any], !imagePaths.isEmpty {
                imagePaths[0] = base64Image
                asset["p"] = imagePaths
                assets[index] = asset
                break
            } else {
                asset["p"] = base64Image
                assets[index] = asset
                break
            }
        }

        modifiedJson["assets"] = assets
        return modifiedJson
    }
    
    func clearAssetImage(in json: [String: Any], assetId: String) -> [String: Any] {
        var modifiedJson = json

        guard var assets = modifiedJson["assets"] as? [[String: Any]] else {
            return modifiedJson
        }

        for (index, var asset) in assets.enumerated() {
            guard asset["id"] as? String == assetId else { continue }

            if let _ = asset["p"] as? String {
                asset["p"] = ""
                assets[index] = asset
                break
            } else if var imagePaths = asset["p"] as? [Any], !imagePaths.isEmpty {
                imagePaths[0] = ""
                asset["p"] = imagePaths
                assets[index] = asset
                break
            } else {
                asset["p"] = ""
                assets[index] = asset
                break
            }
        }

        modifiedJson["assets"] = assets
        return modifiedJson
    }

    func clearAllAssetImages(in json: [String: Any]) -> [String: Any] {
        let assetIds: [String] = ["headtop", "headdecor", "body", "foot"]
        var modifiedJson = json
        let targetIds = Set(assetIds)

        guard var assets = modifiedJson["assets"] as? [[String: Any]] else {
            return modifiedJson
        }

        for (index, var asset) in assets.enumerated() {
            guard let id = asset["id"] as? String,
                  targetIds.contains(id) else { continue }

            if let _ = asset["p"] as? String {
                asset["p"] = ""
                assets[index] = asset
            } else if var imagePaths = asset["p"] as? [Any], !imagePaths.isEmpty {
                imagePaths[0] = ""
                asset["p"] = imagePaths
                assets[index] = asset
            } else {
                asset["p"] = ""
                assets[index] = asset
            }
        }

        modifiedJson["assets"] = assets
        return modifiedJson
    }

    // MARK: - Helpers

    private func downloadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw LottieError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw LottieError.invalidResponse
        }
        return data
    }

    // PNG 시그니처 검사 (89 50 4E 47 0D 0A 1A 0A)
    private func isValidPNG(_ data: Data) -> Bool {
        let pngSignature: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        guard data.count >= pngSignature.count else { return false }
        return data.prefix(pngSignature.count).elementsEqual(pngSignature)
    }
}
