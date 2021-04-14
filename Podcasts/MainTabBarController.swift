//
//  MainTabBarViewController.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 04.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .purple
        setupViewControllers()
        setupPlayerDetailsView()
    }
   
    func minimizePlayerDetails() {
            maximizedTopAnchorConstraint.isActive = false
            bottomAnchorConstraint.constant = view.frame.height
            minimizedTopAnchorConstraint.isActive = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.tabBar.isHidden = false
                self.playerDetailsView.DismissBtn.isHidden = true
                self.playerDetailsView.miniPlayerView.alpha = 1
                self.playerDetailsView.playerStackView.alpha = 0
            })
        }
    
    func maximizePlayerDetails(episode : Episode?,playlistEpisodes:[Episode] = []) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0 // vozmozhno
        bottomAnchorConstraint.constant = 0
        if episode != nil {
            playerDetailsView.episode = episode
        }
        playerDetailsView.playlistEpisodes = playlistEpisodes
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.isHidden = true
            self.playerDetailsView.miniPlayerView.alpha = 0
            self.playerDetailsView.DismissBtn.isHidden = false
            self.playerDetailsView.playerStackView.alpha = 1
        })
    }
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    var maximizedTopAnchorConstraint:NSLayoutConstraint!
    var minimizedTopAnchorConstraint:NSLayoutConstraint!
    var bottomAnchorConstraint:NSLayoutConstraint!
        fileprivate func setupPlayerDetailsView() {
            view.insertSubview(playerDetailsView, belowSubview: tabBar)
            playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
            maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
            maximizedTopAnchorConstraint.isActive = true
            bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
            bottomAnchorConstraint.isActive = true
            minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
            playerDetailsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            playerDetailsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
    
    func setupViewControllers(){
        let layout = UICollectionViewFlowLayout()
        let favoritesController =
            FavoritesController(collectionViewLayout: layout)
        viewControllers = [
                generateNavController(for: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
                generateNavController(for: favoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
                generateNavController(for: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
               ]
    }
    
    fileprivate func generateNavController(for rootViewController:UIViewController, title: String, image: UIImage) -> UIViewController{
        let navigationController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navigationController.title = title
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem.image = image
        return navigationController
    }
}
