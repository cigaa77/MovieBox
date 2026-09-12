//
//  TMDBService.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 08.09.26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
}

private enum MovieEndpoint: String {
    case popular = "/movie/popular"
    case nowPlaying = "/movie/now_playing"
    case topRated = "/movie/top_rated"
}

final class TMDBService {

    private let baseURL = "https://api.themoviedb.org/3"

    func fetchPopularMovies() async throws -> MovieResponse {
        try await fetchMovies(endpoint: .popular)
    }

    func fetchNowPlayingMovies() async throws -> MovieResponse {
        try await fetchMovies(endpoint: .nowPlaying)
    }

    func fetchTopRatedMovies() async throws -> MovieResponse {
        try await fetchMovies(endpoint: .topRated)
    }

    private func fetchMovies(endpoint: MovieEndpoint) async throws
        -> MovieResponse
    {
        let urlString = "\(baseURL)\(endpoint.rawValue)"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
        ]
        components?.queryItems = queryItems

        guard let finalUrl = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalUrl)

        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(APIConfig.tmdbAccessToken)",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let movieResponse = try decoder.decode(MovieResponse.self, from: data)

        return movieResponse
    }

    func searchMovies(query: String) async throws -> MovieResponse {

        let urlString = "\(baseURL)/search/movie"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "age", value: "1"),
        ]

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(APIConfig.tmdbAccessToken)",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let movieResponse = try decoder.decode(MovieResponse.self, from: data)

        return movieResponse
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {

        let urlString = "\(baseURL)/movie/\(id)"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "language", value: "en-US")
        ]

        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(APIConfig.tmdbAccessToken)",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(MovieDetail.self, from: data)
    }

    func fetchMovieReleaseDates(id: Int) async throws
        -> MovieReleaseDatesResponse
    {

        let urlString = "\(baseURL)/movie/\(id)/release_dates"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(APIConfig.tmdbAccessToken)",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()

        return try decoder.decode(
            MovieReleaseDatesResponse.self,
            from: data
        )
    }
}
