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

    func fetchMovieDetail(id: Int) async throws {

        async let detailRequest = service.fetchMovieDetail(id: id)
        async let releaseDatesRequest = service.fetchMovieReleaseDates(id: id)

        let (detail, releasesDate) = try await (
            detailRequest, releaseDatesRequest
        )

        movieDetail = detail

        certification =
            releasesDate.results.first { result in
                result.countryCode == "US"
            }?.releaseDates.first { releaseDate in
                !releaseDate.certification.isEmpty
            }?.certification
    }
}
