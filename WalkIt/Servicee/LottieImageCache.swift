
import Foundation
import UIKit

class LottieImageCache {
    static let shared = LottieImageCache()
    private let memoryCache = NSCache<NSString, NSString>()
    
    private init() {}
    
    // MARK: - 메모리 캐시
    func getMemoryCache(for key: String) -> String? {
        return memoryCache.object(forKey: key as NSString) as String?
    }
    
    func setMemoryCache(_ base64: String, for key: String) {
        memoryCache.setObject(base64 as NSString, forKey: key as NSString)
    }
    
    // MARK: - 디스크 캐시
    func saveBase64ToDisk(_ base64: String, urlKey: String) {
        let cacheURL = getCacheURL(for: urlKey)
        try? base64.write(to: cacheURL, atomically: true, encoding: .utf8)
    }

    func loadBase64FromDisk(urlKey: String) -> String? {
        let cacheURL = getCacheURL(for: urlKey)
        return try? String(contentsOf: cacheURL, encoding: .utf8)
    }

    func isCachedOnDisk(urlKey: String) -> Bool {
        let cacheURL = getCacheURL(for: urlKey)
        return FileManager.default.fileExists(atPath: cacheURL.path)
    }

    func getCacheURL(for key: String) -> URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let safeFileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return caches.appendingPathComponent(safeFileName)
    }
    
    // MARK: - 로딩
    func loadBase64(from url: URL, completion: @escaping (String?) -> Void) {
        let urlString = url.absoluteString
        
        // 1️⃣ 메모리 캐시 확인
        if let cached = getMemoryCache(for: urlString) {
            completion(cached)
            return
        }
        
        // 2️⃣ 디스크 캐시 확인
        if let cachedDisk = loadBase64FromDisk(urlKey: urlString) {
            setMemoryCache(cachedDisk, for: urlString)
            completion(cachedDisk)
            return
        }
        
        // 3️⃣ 없으면 다운로드 후 변환
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard let data = data, let image = UIImage(data: data),
                  let base64 = image.pngData()?.base64EncodedString() else {
                completion(nil)
                return
            }
            
            // 캐싱
            self.setMemoryCache(base64, for: urlString)
            self.saveBase64ToDisk(base64, urlKey: urlString)
            
            completion(base64)
        }.resume()
    }
}

