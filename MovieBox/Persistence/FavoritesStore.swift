//
//  FavoritesStore.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 14.09.26.
//

import CoreData

final class FavoritesStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.context)
    {
        self.context = context
    }

    func save(movie: Movie) throws {

        guard try !isFavorite(movieID: movie.id) else { return }

        let favorite = FavoriteMovie(context: context)

        favorite.id = Int64(movie.id)
        favorite.title = movie.title
        favorite.overview = movie.overview
        favorite.posterPath = movie.posterPath
        favorite.backdropPath = movie.backdropPath
        favorite.releaseDate = movie.releaseDate
        favorite.voteAverage = movie.voteAverage
        favorite.voteCount = Int64(movie.voteCount)

        try context.save()
    }

    func isFavorite(movieID: Int) throws -> Bool {
        let request = FavoriteMovie.fetchRequest()

        request.predicate = NSPredicate(format: "id == %lld", Int64(movieID))

        let count = try context.count(for: request)

        return count > 0
    }

    func remove(movieID: Int) throws {
        let request = FavoriteMovie.fetchRequest()

        request.predicate = NSPredicate(format: "id == %lld", Int64(movieID))

        let favorites = try context.fetch(request)

        for favorite in favorites {
            context.delete(favorite)
        }

        try context.save()
    }

    func fetchFavorites() throws -> [Movie] {
        let request = FavoriteMovie.fetchRequest()

        let favorites = try context.fetch(request)

        return favorites.map { favorite in
            Movie(
                id: Int(favorite.id),
                title: favorite.title ?? "",
                overview: favorite.overview ?? "",
                posterPath: favorite.posterPath,
                backdropPath: favorite.backdropPath,
                releaseDate: favorite.releaseDate ?? "",
                voteAverage: favorite.voteAverage,
                voteCount: Int(favorite.voteCount)
            )
        }
    }
}
