//
//  MovieDetail.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 11.09.26.
//

import Foundation

struct MovieDetail: Decodable {
    let id: Int
    let title: String
    let overview: String
    let backdropPath: String?
    let releaseDate: String
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [Genre]
}

struct Genre: Codable {
    let id: Int
    let name: String
}
