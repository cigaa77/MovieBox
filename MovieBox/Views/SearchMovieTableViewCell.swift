//
//  SearchMovieTableViewCell.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 09.09.26.
//

import UIKit

final class SearchMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLAbel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    private let imageLoader = ImageLoader.shared
    private var imageTask: Task<Void, Never>?

    override func awakeFromNib() {
        super.awakeFromNib()

        posterImageView.layer.cornerRadius = 8
        posterImageView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageTask?.cancel()
        imageTask = nil

        posterImageView.image = UIImage(systemName: "film")
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.tintColor = .secondaryLabel
        posterImageView.backgroundColor = .secondarySystemBackground
        
        titleLabel.text = nil
            infoLAbel.text = nil
            overviewLabel.text = nil
    }

    func configure(movie: Movie) {
        titleLabel.text = movie.title

        let year = String(movie.releaseDate.prefix(4))
        infoLAbel.text =
            "\(year)  •  ⭐ \(String(format: "%.1f", movie.voteAverage))"

        overviewLabel.text = movie.overview

        posterImageView.image = UIImage(systemName: "film")
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.tintColor = .secondaryLabel
        posterImageView.backgroundColor = .secondarySystemBackground

        guard let posterUrl = movie.posterURL else { return }

        imageTask = Task {
            do {
                let image = try await imageLoader.loadImage(from: posterUrl)

                guard !Task.isCancelled else { return }

                posterImageView.image = image
                posterImageView.contentMode = .scaleAspectFill
            } catch is CancellationError {
                print("CAncellation Error Search")
            } catch {
                print("Search poster error:", error)
            }
        }
    }

}
