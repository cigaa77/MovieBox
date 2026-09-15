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
    @IBOutlet weak var loadingOverlayView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    var movie: Movie?
    private let viewModel = MovieDetailViewModel()
    private let favoritesStore = FavoritesStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        castCollectionView.delegate = self
        castCollectionView.dataSource = self

        similarMoviesCollectionView.delegate = self
        similarMoviesCollectionView.dataSource = self

        guard let movie else { return }

        configure(with: movie)
        updateFavoriteButton()

        loadMovieDetails()
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset.bottom = 30

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = true
        edgesForExtendedLayout = [.top]
        
        let apperance = UINavigationBarAppearance()
        apperance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = apperance
        navigationController?.navigationBar.scrollEdgeAppearance = apperance
    }

    private func loadMovieDetails() {
        guard let movie else { return }
        Task {

            loadingOverlayView.isHidden = false
            activityIndicator.startAnimating()
            errorView.isHidden = true

            defer {
                loadingOverlayView.isHidden = true
                activityIndicator.stopAnimating()
            }
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

            } catch {
                errorView.isHidden = false
                print(error)
            }
        }
    }

    @IBAction func tryAgainButtonTapped(_ sender: UIButton) {
        loadMovieDetails()
    }

    private func configure(with movie: Movie) {

        titleLabel.text = movie.title

        let year = String(movie.releaseDate.prefix(4))
        infoLabel.text = year

        let countString = formatVoteCount(voteCount: movie.voteCount)
        ratingLabel.text =
            "⭐ \(String(format: "%.1f", movie.voteAverage))  •  \(countString) votes"

        overviewLabel.text = movie.overview

        backdropImageView.image = UIImage(systemName: "film")
        backdropImageView.contentMode = .scaleAspectFit
        backdropImageView.tintColor = .secondaryLabel
        backdropImageView.backgroundColor = .secondarySystemBackground

        guard let backdropURL = movie.backdropURL else {
            return
        }

        Task {
            do {
                let image = try await ImageLoader.shared.loadImage(
                    from: backdropURL
                )

                backdropImageView.image = image
                backdropImageView.contentMode = .scaleAspectFill
            } catch {
                print(error)
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

    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let movie else { return }

        do {
            let isFavorite = try favoritesStore.isFavorite(movieID: movie.id)

            if isFavorite {
                try favoritesStore.remove(movieID: movie.id)
            } else {
                try favoritesStore.save(movie: movie)
            }
            updateFavoriteButton()

        } catch {
            print(error)
        }
    }

    private func updateFavoriteButton() {
        guard let movie else { return }

        do {
            let isFavorite = try favoritesStore.isFavorite(movieID: movie.id)

            let imageName = isFavorite ? "heart.fill" : "heart"

            favoriteButton.setImage(
                UIImage(systemName: imageName),
                for: .normal
            )
            favoriteButton.tintColor = .systemYellow

        } catch { print(error) }

    }

    private func formatVoteCount(voteCount: Int) -> String {
        switch voteCount {
        case 0...999:
            return "\(voteCount)"
        case 1000...999_999:
            let count = Double(voteCount) / 1000.0
            return String(format: "%.1fK", count)
        default:
            let count = Double(voteCount) / 1_000_000.0
            return String(format: "%.1fM", count)
        }
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

        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
