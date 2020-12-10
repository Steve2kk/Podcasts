//
//  DownloadsController.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 20.11.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit
class DownloadsController: UITableViewController {
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    override func viewDidLoad(){
        super.viewDidLoad()
        setupTableView()
        setupObservers()
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self,selector:#selector(handleDownloadProgress),name: .downloadProgress,object:nil)
        NotificationCenter.default.addObserver(self,selector:#selector(handleDownloadComplete),name: .downloadComplete,object:nil)
    }
    
    @objc func handleDownloadComplete (notification: Notification) {
        guard let episodeDownloadComplete = notification.object as? APIService.episodeDownloadCompleteTuple else {return }
        guard let index = self.episodes.firstIndex(where: {$0.title == title}) else {return}
        self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
    }
    @objc func handleDownloadProgress (notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:Any] else {return}
        guard let progress = userInfo["progress"] as? Double else {return}
        guard let title = userInfo["title"] as? String else {return}
        print(progress,title)
        guard let index = self.episodes.firstIndex(where: {$0.title == title}) else {return}
        guard let cell = tableView.cellForRow(at: IndexPath(row: index,section: 0)) as? EpisodeViewCell else {return}
        cell.progressLabel.text = "\(Int(progress*100))%"
        cell.progressLabel.isHidden = false
        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
    }
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }
    
//MARK:- Setup
    fileprivate let cellId = "cellId"
    fileprivate func setupTableView(){
        let nib = UINib(nibName:"EpisodeViewCell",bundle:nil)
        tableView.register(nib,forCellReuseIdentifier:cellId)
    }
//MARK:- UITableView
    override func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath){
        let episode = self.episodes[indexPath.row]
        
        if episode.fileUrl != nil {
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode:episode,playlistEpisodes: self.episodes)
        }else {
            let alertController = UIAlertController(title:"File url not found",message: "Cannot find local file,do you want to play using your network trafic?",preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title:"Yes",style: .default,handler: {(_) in
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode:episode,playlistEpisodes: self.episodes)
            }))
            alertController.addAction(UIAlertAction(title:"Cancel",style: .cancel))
            present(alertController,animated:true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        episodes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UserDefaults.standard.deleteEpisode(episode: episode)
    }
    
    override func tableView(_ tableView:UITableView,numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:cellId,for: indexPath) as!  EpisodeViewCell
        cell.episode = self.episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView:UITableView,heightForRowAt indexPath:IndexPath) -> CGFloat {
        return 132
    }
}
