//
//  MovieCollectionViewCell.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 08.09.26.
//

import UIKit

final class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

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
        ratingLabel.text = nil
    }

    func configure(title: String, rating: Double, posterURL: URL?) {

        posterImageView.image = UIImage(systemName: "film")
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.tintColor = .secondaryLabel
        posterImageView.backgroundColor = .secondarySystemBackground

        titleLabel.text = title
        ratingLabel.text = "⭐️ \(String(format: "%.1f", rating))"
        
        guard let posterURL else {
            return
        }

        imageTask = Task {
            do {
                let image = try await imageLoader.loadImage(from: posterURL)

                guard !Task.isCancelled else {
                    return
                }

                posterImageView.image = image
                posterImageView.contentMode = .scaleAspectFill
            } catch is CancellationError {
                // Cell reuse nedeniyle iptal edildi.
            } catch {
                print("Image loading error:", error)
            }
        }
    }

}
