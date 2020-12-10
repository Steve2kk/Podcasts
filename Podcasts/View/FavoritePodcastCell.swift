//
//  FavoriteViewCell.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 17.11.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
 
    var podcast: Podcast! {
        didSet{
            nameLabelView.text = podcast.trackName
            artistNameLabelView.text = podcast.artistName
            let url = URL(string: podcast.artworkUrl600 ?? "")
            imageView.sd_setImage(with: url)
        }
    }
    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    let nameLabelView = UILabel()
    let artistNameLabelView = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        stylizeUI()
        setupStackView()
    }
    
    fileprivate func stylizeUI() {
        nameLabelView.text = "Hello"
        nameLabelView.font = UIFont.systemFont(ofSize: 16,weight: .semibold)
        artistNameLabelView.text = "World"
        artistNameLabelView.font = UIFont.systemFont(ofSize: 14)
        artistNameLabelView.textColor = .lightGray
    }
    fileprivate func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [imageView,nameLabelView,artistNameLabelView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder :) has not been implemented")
    }
    
}
