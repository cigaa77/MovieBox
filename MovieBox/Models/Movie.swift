//
//  Movie.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 08.09.26.
//

import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int

    var posterURL: URL? {
        guard let posterPath else {
            return nil
        }

        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var backdropURL: URL? {
        guard let backdropPath else { return nil }

        return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath)")
    }
}

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}
