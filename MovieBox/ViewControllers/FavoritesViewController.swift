//
//  FavoritesViewController.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 08.09.26.
//

import UIKit

final class FavoritesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let favoritesStore = FavoritesStore()
    private var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadFavorites()
    }

    private func loadFavorites() {
        do {
            movies = try favoritesStore.fetchFavorites()
            collectionView.reloadData()
            updateEmptyState()
        } catch {
            print(error)
        }
    }

    private func updateEmptyState() {
        if movies.isEmpty {
            let label = UILabel()
            label.text = "No favorites yet"
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 17, weight: .medium)

            collectionView.backgroundView = label
        } else {
            collectionView.backgroundView = nil
        }
    }
}

extension FavoritesViewController: UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return movies.count
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
        else { return UICollectionViewCell() }

        let movie = movies[indexPath.item]

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
        let witdh = (collectionView.bounds.width - spacing) / 2

        return CGSize(width: witdh, height: 285)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedMovie = movies[indexPath.item]

        guard
            let detailVC = storyboard?.instantiateViewController(
                withIdentifier: "MovieDetailViewController"
            ) as? MovieDetailViewController
        else { return }

        detailVC.movie = selectedMovie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
