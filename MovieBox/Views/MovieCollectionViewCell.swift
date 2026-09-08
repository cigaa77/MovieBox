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

    override func awakeFromNib() {
        super.awakeFromNib()

        posterImageView.layer.cornerRadius = 8
        posterImageView.clipsToBounds = true
    }

    func configure(title: String, rating: Double, imageName: String) {

        if let image = UIImage(named: imageName), !imageName.isEmpty {
            posterImageView.image = image
            posterImageView.contentMode = .scaleAspectFill
        } else {
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.contentMode = .scaleAspectFit
            posterImageView.tintColor = .secondaryLabel
            posterImageView.backgroundColor = .secondarySystemBackground
        }
        titleLabel.text = title
        ratingLabel.text = "⭐️ \(rating)"
    }

}
