//
//  MovieDetailViewController.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 09.09.26.
//

import UIKit

final class MovieDetailViewController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var castCollectionView: UICollectionView!
    @IBOutlet weak var similarMoviesCollectionView: UICollectionView!

    var movie: Movie?
    private let viewModel = MovieDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        castCollectionView.delegate = self
        castCollectionView.dataSource = self

        similarMoviesCollectionView.delegate = self
        similarMoviesCollectionView.dataSource = self

        guard let movie else { return }

        configure(with: movie)

        Task {
            do {
                try await viewModel.fetchMovieDetail(id: movie.id)

                guard let detail = viewModel.movieDetail else { return }

                let genresText = detail.genres
                    .map { $0.name }
                    .joined(separator: " • ")

                genresLabel.text = genresText

                var infoParts: [String] = []

                let year = String(detail.releaseDate.prefix(4))
                infoParts.append(year)

                if let runtime = detail.runtime,
                    let runtimeText = formatRuntime(runtime)
                {
                    infoParts.append(runtimeText)
                }

                if let certification = viewModel.certification {
                    infoParts.append(certification)
                }

                infoLabel.text = infoParts.joined(separator: " • ")

                if let director = viewModel.director {
                    directorLabel.text = "Director: \(director.name)"
                }

                castCollectionView.reloadData()
                similarMoviesCollectionView.reloadData()

            } catch { print(error) }
        }
    }

    private func configure(with movie: Movie) {

        titleLabel.text = movie.title

        let year = String(movie.releaseDate.prefix(4))
        infoLabel.text = year

        ratingLabel.text =
            "⭐ \(String(format: "%.1f", movie.voteAverage))  •  \(movie.voteCount) votes"

        overviewLabel.text = movie.overview

        if let backdropURL = movie.backdropURL {

            Task {
                do {
                    let image = try await ImageLoader.shared.loadImage(
                        from: backdropURL
                    )
                    backdropImageView.image = image
                } catch {
                    print(error)
                }
            }

        }

    }

    private func formatRuntime(_ runtime: Int) -> String? {

        guard runtime > 0 else { return nil }

        let hours = runtime / 60
        let minutes = runtime % 60

        if hours == 0 {
            return "\(minutes)m"
        }

        if minutes == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(minutes)m"
    }
}

extension MovieDetailViewController: UICollectionViewDelegate,
    UICollectionViewDataSource
{

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        if collectionView == castCollectionView {
            return viewModel.cast.count
        } else {
            return viewModel.similarMovies.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if collectionView == castCollectionView {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "CastCell",
                    for: indexPath
                ) as? CastCollectionViewCell
            else { return UICollectionViewCell() }

            let castMember = viewModel.cast[indexPath.item]
            cell.configure(with: castMember)

            return cell
        } else {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "MovieCell",
                    for: indexPath
                ) as? MovieCollectionViewCell
            else { return UICollectionViewCell() }

            let movie = viewModel.similarMovies[indexPath.item]
            cell.configure(
                title: movie.title,
                rating: movie.voteAverage,
                posterURL: movie.posterURL
            )
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard collectionView == similarMoviesCollectionView else { return }

        let selectedMovie = viewModel.similarMovies[indexPath.item]

        guard
            let detailVC = storyboard?.instantiateViewController(
                withIdentifier: "MovieDetailViewController"
            ) as? MovieDetailViewController
        else { return }

        detailVC.movie = selectedMovie

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
