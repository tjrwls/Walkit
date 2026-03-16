//
//  KeychainManager.swift
//  WalkIt
//
//  Created by 조석진 on 1/17/26.
//

import Security
import Foundation

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    func save(key: String, value: String?) {
        guard let value = value else {
            delete(key: key)
            return
        }

        let data = Data(value.utf8)

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]

        SecItemDelete(query as CFDictionary) // 중복 방지
        SecItemAdd(query as CFDictionary, nil)
    }

    func read(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]

        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Token Accessors

    var accessToken: String? {
        get { read(key: "accessToken") }
        set { save(key: "accessToken", value: newValue) }
    }

    var refreshToken: String? {
        get { read(key: "refreshToken") }
        set { save(key: "refreshToken", value: newValue) }
    }

    func clear() {
        delete(key: "accessToken")
        delete(key: "refreshToken")
    }
}
