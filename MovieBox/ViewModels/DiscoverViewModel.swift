//
//  DiscoverViewModel.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 08.09.26.
//

import Foundation

final class DiscoverViewModel {
    private(set) var popularMovies: [Movie] = []
    private(set) var nowPlayingMovies: [Movie] = []
    private(set) var topRatedMovies: [Movie] = []

    private let service = TMDBService()

    func fetchMovies() async throws {

        async let popularResponse = service.fetchPopularMovies()
        async let nowPlayingResponse = service.fetchNowPlayingMovies()
        async let topRatedResponse = service.fetchTopRatedMovies()

        let (popular, nowPlaying, topRated) = try await (
            popularResponse, nowPlayingResponse, topRatedResponse
        )

        popularMovies = popular.results
        nowPlayingMovies = nowPlaying.results
        topRatedMovies = topRated.results
    }
}
