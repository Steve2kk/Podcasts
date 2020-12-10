//
//  Podcast.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 05.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import Foundation

class Podcast:NSObject,Decodable, NSCoding{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackName ?? "",forKey: "trackNameKey")
        aCoder.encode(artistName ?? "",forKey: "artistNameKey")
        aCoder.encode(artworkUrl600 ?? "",forKey: "artworkKey")
        aCoder.encode(feedUrl ?? "",forKey: "feedUrlKey")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkKey") as? String
        self.feedUrl = aDecoder.decodeObject(forKey: "feedUrlKey") as? String
    }
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
