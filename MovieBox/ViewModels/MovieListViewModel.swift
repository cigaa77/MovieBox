//
//  MovieListViewModel.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 14.09.26.
//

import Foundation

final class MovieListViewModel {

    private let service = TMDBService()

    private(set) var movies: [Movie] = []

    func fetchMovies(for category: MovieCategory) async throws {

        switch category {
        case .nowPlaying:
            let response = try await service.fetchNowPlayingMovies()
            movies = response.results
        case .popular:
            let response = try await service.fetchPopularMovies()
            movies = response.results
        case .topRated:
            let response = try await service.fetchTopRatedMovies()
            movies = response.results
        }
    }
}
