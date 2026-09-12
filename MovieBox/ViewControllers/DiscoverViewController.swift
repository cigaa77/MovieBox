//
//  ViewController.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 08.09.26.
//

import UIKit

class DiscoverViewController: UIViewController {

    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var nowPlayingCollectionView: UICollectionView!
    @IBOutlet weak var topRatedCollectionView: UICollectionView!

    private let viewModel = DiscoverViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self

        nowPlayingCollectionView.delegate = self
        nowPlayingCollectionView.dataSource = self

        topRatedCollectionView.delegate = self
        topRatedCollectionView.dataSource = self

        Task {
            do {
                try await viewModel.fetchMovies()

                popularCollectionView.reloadData()
                nowPlayingCollectionView.reloadData()
                topRatedCollectionView.reloadData()

            } catch {
                print("Error: ", error)
            }
        }

    }

}

// MARK: - UICollectionView DataSource & Delegate

extension DiscoverViewController: UICollectionViewDelegate,
    UICollectionViewDataSource
{

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        switch collectionView {
        case popularCollectionView:
            return viewModel.popularMovies.count
        case nowPlayingCollectionView:
            return viewModel.nowPlayingMovies.count
        case topRatedCollectionView:
            return viewModel.topRatedMovies.count
        default:
            return 0

        }
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

        let movie: Movie

        switch collectionView {
        case popularCollectionView:
            movie = viewModel.popularMovies[indexPath.item]
        case topRatedCollectionView:
            movie = viewModel.topRatedMovies[indexPath.item]
        case nowPlayingCollectionView:
            movie = viewModel.nowPlayingMovies[indexPath.item]
        default:
            fatalError("Unhandled collection view")
        }

        cell.configure(
            title: movie.title,
            rating: movie.voteAverage,
            posterURL: movie.posterURL
        )

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        let movie: Movie

        switch collectionView {
        case popularCollectionView:
            movie = viewModel.popularMovies[indexPath.item]
        case topRatedCollectionView:
            movie = viewModel.topRatedMovies[indexPath.item]
        case nowPlayingCollectionView:
            movie = viewModel.nowPlayingMovies[indexPath.item]
        default:
            return
        }

        guard
            let detailVC = storyboard?.instantiateViewController(
                identifier: "MovieDetailViewController"
            ) as? MovieDetailViewController
        else { return }

        detailVC.movie = movie

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
