//
//  NetworkClient.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case httpError(Int)
    case decodingError
    case unknown(Error)
    case unauthorized
}

final class NetworkClient {
    func request<T: Decodable>(_ request: URLRequest, responseType: T.Type, isRetry: Bool = false) async throws -> T {

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                debugPrint("request \(http.statusCode)")
            }

            guard let http = response as? HTTPURLResponse else {
                debugPrint("url에러: \(request)")
                throw NetworkError.invalidURL
            }

            // 🔑 여기만 추가
            if (http.statusCode == 401), isRetry == false {
                debugPrint("토큰 만료 → refresh 시도 \(http.statusCode)")

                do {
                    try await AuthManager.shared.getRefreshToken()
                    guard let accessToken = AuthManager.shared.authToken?.accessToken else {
                        throw NetworkError.httpError(http.statusCode)
                    }
                    
                    var retryRequest = request
                    retryRequest.setValue(
                        "Bearer \(accessToken)",
                        forHTTPHeaderField: "Authorization"
                    )

                    return try await self.request(
                        retryRequest,
                        responseType: responseType,
                        isRetry: true
                    )
                } catch {
                    debugPrint("refresh 실패")
                    throw NetworkError.unauthorized
                }
            }

            guard (200..<300).contains(http.statusCode) else {
                debugPrint("http에러: \(http.statusCode)")
                throw NetworkError.httpError(http.statusCode)
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                debugPrint("디코딩 실패 data: \(String(data: data, encoding: .utf8) ?? "")")
                throw NetworkError.decodingError
            }

        } catch {
            throw NetworkError.unknown(error)
        }
    }


    func requestVoid(_ request: URLRequest) async throws {
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http2 = response as? HTTPURLResponse {
                debugPrint("requestVoid \(http2.statusCode)")
            }
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw NetworkError.invalidURL
            }
        } catch {
            debugPrint("알수없는 에러: \(error)")
            throw NetworkError.unknown(error)
        }
    }
}
