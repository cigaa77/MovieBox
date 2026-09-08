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
        return mockMovies.count
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

        let movie = mockMovies[indexPath.item]
        cell.configure(title: movie.0, rating: movie.1, imageName: "")

        return cell
    }
}

private let mockMovies = [
    ("Dune", 8.2),
    ("Oppenheimer", 8.5),
    ("The Batman", 7.8),
    ("Interstellar", 8.7),
]
