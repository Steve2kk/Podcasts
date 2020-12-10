//
//  Episode.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 10.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit
import FeedKit

struct Episode:Codable  {
    let title: String
    let pubDate: Date
    let description: String
    var imageUrl : String?
    var author: String?
    var streamURL: String
    var fileUrl: String?
    init(feedItem: RSSFeedItem){
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        self.streamURL = feedItem.enclosure?.attributes?.url ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    }
}
