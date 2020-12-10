//
//  EpisodeViewCell.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 10.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit

class EpisodeViewCell: UITableViewCell {
    var episode : Episode! {
        didSet {
            descriptionLabel.text = episode.description
            titleLabel.text = episode.title
            let formater = DateFormatter()
            formater.dateFormat = "MMM dd, yyyy"
            dateLabel.text = formater.string(from: episode.pubDate)
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            EpisodeImageView.sd_setImage(with: url)
        }
    }
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var EpisodeImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
}
