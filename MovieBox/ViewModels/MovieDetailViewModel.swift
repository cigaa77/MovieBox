//
//  MovieDetailViewModel.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 11.09.26.
//

import Foundation

final class MovieDetailViewModel {

    private let service = TMDBService()
    private(set) var movieDetail: MovieDetail?
    private(set) var certification: String?
    private(set) var cast: [CastMember] = []
    private(set) var director: CrewMember?

    func fetchMovieDetail(id: Int) async throws {

        async let detailRequest = service.fetchMovieDetail(id: id)
        async let releaseDatesRequest = service.fetchMovieReleaseDates(id: id)
        async let creditRequest = service.fetchMovieCredits(id: id)

        let (detail, releasesDate, credits) = try await (
            detailRequest, releaseDatesRequest, creditRequest
        )

        movieDetail = detail
        cast = credits.cast
        director = credits.crew.first(where: { $0.job == "Director" })

        certification =
            releasesDate.results.first { result in
                result.countryCode == "US"
            }?.releaseDates.first { releaseDate in
                !releaseDate.certification.isEmpty
            }?.certification
    }
}
