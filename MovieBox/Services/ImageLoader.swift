//
//  ImageLoader.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 09.09.26.
//

import UIKit

final class ImageLoader {

    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func loadImage(from url: URL) async throws -> UIImage {

        let key = url as NSURL

        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        guard let image = UIImage(data: data) else {
            throw NetworkError.invalidResponse
        }

        cache.setObject(image, forKey: key)

        return image

    }
}
