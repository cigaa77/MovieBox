//
//  SearchViewModel.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 09.09.26.
//

import Foundation

final class SearchViewModel {

    private let service = TMDBService()

    private(set) var movies: [Movie] = []

    func searchMovies(query: String) async throws {
        let response = try await service.searchMovies(query: query)

        movies = response.results
    }

    func clearResults() {
        movies = []
    }

}
