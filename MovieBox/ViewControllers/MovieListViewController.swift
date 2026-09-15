//
//  MovieListViewController.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 14.09.26.
//

import UIKit

final class MovieListViewController: UIViewController {

    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingOverlayView: UIView!
    @IBOutlet weak var errorView: UIView!

    private let viewModel = MovieListViewModel()

    var category: MovieCategory!

    override func viewDidLoad() {
        super.viewDidLoad()

        listCollectionView.delegate = self
        listCollectionView.dataSource = self

        loadMovies()

        navigationItem.largeTitleDisplayMode = .never
        switch category {
        case .popular:
            title = "Popular"
        case .nowPlaying:
            title = "Now Playing"
        case .topRated:
            title = "Top Rating"
        default:
            title = ""
        }
    }

    private func loadMovies() {

        Task {
            loadingOverlayView.isHidden = false
            activityIndicator.startAnimating()
            errorView.isHidden = true

            defer {
                loadingOverlayView.isHidden = true
                activityIndicator.stopAnimating()
            }
            do {
                try await viewModel.fetchMovies(for: category)
                listCollectionView.reloadData()
            } catch {
                errorView.isHidden = false
                print(error)
            }
        }
    }

    @IBAction func retryButtonTapped(_ sender: Any) {
        loadMovies()
    }
}

extension MovieListViewController: UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.movies.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MovieCell",
                for: indexPath
            ) as? MovieCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        let movie = viewModel.movies[indexPath.item]
        cell.configure(
            title: movie.title,
            rating: movie.voteAverage,
            posterURL: movie.posterURL
        )

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let spacing: CGFloat = 12
        let totalSpacing = spacing * 2
        let width = (collectionView.bounds.width - totalSpacing) / 3

        return CGSize(width: width, height: 210)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        let selectedItem = viewModel.movies[indexPath.item]

        guard
            let detailVC = storyboard?.instantiateViewController(
                withIdentifier: "MovieDetailViewController"
            ) as? MovieDetailViewController
        else { return }

        detailVC.movie = selectedItem
        detailVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
