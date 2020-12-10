//
//  PodcastViewCell.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 07.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastViewCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var tracknameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            tracknameLabel.text = podcast.trackName
            artistLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) episodes"
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else {return}
//            URLSession.shared.dataTask(with: url) { (data, _, _) in
//                DispatchQueue.main.async {
//                    guard let data = data else {return}
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//
//            }.resume()
            podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    
    
}
