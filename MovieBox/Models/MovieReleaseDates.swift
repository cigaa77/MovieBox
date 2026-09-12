//
//  MovieReleaseDates.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 12.09.26.
//

import Foundation

struct MovieReleaseDatesResponse: Codable {
    let results: [MovieReleaseDateResult]
}

struct MovieReleaseDateResult: Codable {
    let countryCode: String
    let releaseDates: [MovieReleaseDate]

    enum CodingKeys: String, CodingKey {
        case countryCode = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

struct MovieReleaseDate: Codable {
    let certification: String
}
