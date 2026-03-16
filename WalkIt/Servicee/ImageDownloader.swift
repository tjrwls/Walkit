//
//  ImageDownloader.swift
//  WalkIt
//
//  Created by 조석진 on 1/6/26.
//


import Foundation

final class ImageDownloader {
    func downloadAsBase64(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return "data:image/png;base64," + data.base64EncodedString()
    }
}
