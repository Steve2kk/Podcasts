//
//  UserDefaults.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 19.11.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import Foundation

extension UserDefaults {
    static let userDefaultFavoriteKey = "userDefaultFavoriteKey"
    static let userDefaultDownloadKey = "userDefaultDownloadKey"
    
    func deleteEpisode(episode: Episode) {
        let savedEpisodes = downloadedEpisodes()
        let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
            // you should use episode.collectionId to be safer with deletes
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.userDefaultDownloadKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }
    
    func downloadEpisode(episode: Episode) {
        do {
            var episodes = downloadedEpisodes ()
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data,forKey: UserDefaults.userDefaultDownloadKey)
        } catch let downloadError {
            print("Problem with download episode",downloadError)
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodeData = data(forKey:UserDefaults.userDefaultDownloadKey) else {return []}
        do {
            let episodes = try JSONDecoder().decode([Episode].self,from:episodeData)
            return episodes
        } catch let decodeError {
            print("Problem with decoding",decodeError)
        }
        return []
    }
    
    func savedPodcasts() -> [Podcast] {
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.userDefaultFavoriteKey) else {return []}
        do {
            let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastsData)
            return savedPodcasts as! [Podcast]
        }
        catch let unArchiveErr {
            print(unArchiveErr)
            return []
        }
    }
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        do {
            let data =  try NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UserDefaults.userDefaultFavoriteKey)
        }
        catch let archiveErr {
            print(archiveErr)
            
        }
    }
}
