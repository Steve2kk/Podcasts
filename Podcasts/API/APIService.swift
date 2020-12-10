//
//  APIService.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 06.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit
import Alamofire
import FeedKit
extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadComplete = NSNotification.Name("downloadComplete")
}
class APIService {
        
    typealias episodeDownloadCompleteTuple = (fileUrl: String,episodeTitle:String)
    static let shared = APIService()
    
    func downloadEpisode(episode:Episode){
        let downRequest = DownloadRequest.suggestedDownloadDestination()
        Alamofire.download(episode.streamURL, to:downRequest).downloadProgress { (progress) in
            NotificationCenter.default.post(name: .downloadProgress,object: nil,userInfo: ["title": episode.title,"progress": progress.fractionCompleted])
        }.response { (resp) in
            print(resp.destinationURL?.absoluteString ?? "")
            let EpisodeDownloadComplete = episodeDownloadCompleteTuple(fileUrl: resp.destinationURL?.absoluteString ?? "",episode.title)
            NotificationCenter.default.post(name: .downloadComplete,object: EpisodeDownloadComplete,userInfo: nil)
            var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
            guard let index = downloadedEpisodes.firstIndex(where: {$0.title == episode.title && $0.author == episode.author}) else {return}
            downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
            do{
                let data = try JSONEncoder().encode(downloadedEpisodes)
                UserDefaults.standard.set(data,forKey: UserDefaults.userDefaultDownloadKey)
            }catch let err{
                print("Failed to encode downloaded episodes with file url update:",err)
            }
           
        }
    }

    func fetchEpisodes(feedUrl: String,completionHandler: @escaping ([Episode]) -> ()){
        let secureFeedUrl = feedUrl.contains("https") ? feedUrl :
        feedUrl.replacingOccurrences(of: "http", with: "https")
        guard let url = URL(string: secureFeedUrl) else {return}
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser?.parseAsync(result: { (result) in
                print("Succesfully parse feed:",result.isSuccess)
                if let err = result.error {
                    print("Failed to parse XML",err)
                    return
                }
                guard let feed = result.rssFeed else {return}
                let episodes = feed.toEpisodes()
                completionHandler(episodes)
            })
        }
    }
    
    func fetchPodcast(searchText:String,completionHandler: @escaping ([Podcast]) -> ()){
        let url = "https://itunes.apple.com/search"
        let parameters = ["term" : searchText,"media":"podcast"]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                    print("Problems with connect to itunes API",err)
                    return
                }
            guard let data = dataResponse.data else {return}
                do{
                    let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                    completionHandler(searchResults.results)
                }catch let decodeError {
                    print("Decode problems",decodeError)
                }
        }
    }
    
    struct SearchResults:Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
}
