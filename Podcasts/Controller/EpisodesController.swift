//
//  EpisodesController.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 09.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import FeedKit

class EpisodesController: UITableViewController {
    
    var podcast:Podcast? {
        didSet{
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl else {return}
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var episodes = [Episode]()
    fileprivate let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setupFavoriteButton()
    }
    
    fileprivate func setupFavoriteButton() {
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let alreadyFavorite = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
        if alreadyFavorite {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title:"",style: .plain,target: nil,action: nil)
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite",style: .plain,target: self,action:#selector(handleSaveFavorite))
        }
    }
    
    @objc func handleFetchSavedPodcast(){
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.userDefaultFavoriteKey) else {return}
        do {
            let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [Podcast]
            savedPodcasts.forEach({(p) in
                print(p.trackName ?? "")
            })
        } catch let unarchivePodcastErr {
            print(unarchivePodcastErr)
        }
    }
    
    @objc func handleSaveFavorite(){
        guard let podcast = self.podcast else {return}
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        listOfPodcasts.append(podcast)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)
            UserDefaults.standard.set(data,forKey: UserDefaults.userDefaultFavoriteKey)
        }catch let archiveErr {
            print(archiveErr)
        }
        showBadgeHighlight()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"",style: .plain,target: nil,action: nil)
    }
    
    fileprivate func showBadgeHighlight(){
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
    }
    //MARK:- UITableView
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       let contextItem = UIContextualAction(style: .normal, title: "Download") { [weak self]  (_, _, _) in
            let episode = self?.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode:episode!)
            APIService.shared.downloadEpisode(episode: episode!)
        if let tabBarController = self?.navigationController?.tabBarController  {
               tabBarController.selectedIndex = 2
           }
       }
       let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
       return swipeActions
   }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    fileprivate func setUpTableView() {
        let nib = UINib(nibName: "EpisodeViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        let mainTabBarController = self.view.window?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: episode,playlistEpisodes: self.episodes)
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeViewCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
}
