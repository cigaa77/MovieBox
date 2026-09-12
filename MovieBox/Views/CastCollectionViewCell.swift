//
//  CastCollectionViewCell.swift
//  MovieBox
//
//  Created by Ahmet CILINGIR on 12.09.26.
//

import UIKit

final class CastCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var characterLabel: UILabel!

    private var imageTask: Task<Void, Never>?

    func configure(with castMember: CastMember) {
        nameLabel.text = castMember.name
        characterLabel.text = castMember.character

        profileImageView.image = UIImage(systemName: "film")

        guard let profilURL = castMember.profileURL else {
            return
        }

        imageTask = Task {
            do {
                let image = try await ImageLoader.shared.loadImage(
                    from: profilURL
                )

                guard !Task.isCancelled else { return }

                profileImageView.image = image

            } catch is CancellationError {

            } catch {
                print(error)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageTask?.cancel()
        imageTask = nil

        profileImageView.image = UIImage(systemName: "film")
        nameLabel.text = nil
        characterLabel.text = nil
    }
}
