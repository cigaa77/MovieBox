//
//  MovieCredits.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 12.09.26.
//

import Foundation

struct MovieCredits: Codable {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Codable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?

    var profileURL: URL? {
        guard let profilePath else { return nil }

        return URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")
    }
}

struct CrewMember: Codable {
    let id: Int
    let name: String
    let job: String
}
