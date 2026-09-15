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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingOverlayView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var movieBoxLabel: UILabel!

    private let viewModel = DiscoverViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .systemBackground
        errorView.isHidden = true

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = nil

        configureMovieBoxTitle()

        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self

        nowPlayingCollectionView.delegate = self
        nowPlayingCollectionView.dataSource = self

        topRatedCollectionView.delegate = self
        topRatedCollectionView.dataSource = self

        loadMovies()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func loadMovies() {
        Task {

            loadingOverlayView.isHidden = false
            errorView.isHidden = true
            activityIndicator.startAnimating()

            defer {
                loadingOverlayView.isHidden = true
                activityIndicator.stopAnimating()
            }

            do {

                try await viewModel.fetchMovies()

                popularCollectionView.reloadData()
                nowPlayingCollectionView.reloadData()
                topRatedCollectionView.reloadData()

            } catch {
                errorView.isHidden = false
                print("Error: ", error)
            }
        }
    }

    private func configureMovieBoxTitle() {
        let title = NSMutableAttributedString(
            string: "Movie",
            attributes: [.foregroundColor: UIColor.label]
        )
        title.append(
            NSAttributedString(
                string: "Box",
                attributes: [.foregroundColor: UIColor.systemYellow]
            )
        )
        movieBoxLabel.attributedText = title
    }

    @IBAction func tryAgainTapped(_ sender: UIButton) {
        loadMovies()
    }

    @IBAction func popularSeeAllTapped(_ sender: UIButton) {
        guard
            let movieListVC = storyboard?.instantiateViewController(
                identifier: "MovieListViewController"
            ) as? MovieListViewController
        else { return }

        movieListVC.category = .popular
        movieListVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieListVC, animated: true)
    }

    @IBAction func nowPlayingSeeAllTapped(_ sender: UIButton) {
        guard
            let movieListVC = storyboard?.instantiateViewController(
                withIdentifier: "MovieListViewController"
            ) as? MovieListViewController
        else { return }

        movieListVC.category = .nowPlaying
        movieListVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieListVC, animated: true)
    }

    @IBAction func topRatedSeeAllTapped(_ sender: UIButton) {
        guard
            let movieListVC = storyboard?.instantiateViewController(
                withIdentifier: "MovieListViewController"
            ) as? MovieListViewController
        else { return }

        movieListVC.category = .topRated
        movieListVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieListVC, animated: true)
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
        detailVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(detailVC, animated: true)
    }
}
