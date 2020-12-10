//
//  FavoritesController.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 17.11.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit
class FavoritesController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    fileprivate let cellId = "cellId"
    var podcasts = UserDefaults.standard.savedPodcasts()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        podcasts = UserDefaults.standard.savedPodcasts()
        collectionView?.reloadData()
        UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    func setupCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.register(FavoritePodcastCell.self,forCellWithReuseIdentifier: cellId)
        let gesture = UILongPressGestureRecognizer(target: self,action: #selector(handleLongPressRecognize))
        collectionView?.addGestureRecognizer(gesture)
    }
    @objc func handleLongPressRecognize(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else {return}
        let alertController = UIAlertController(title:"Remove podcast?",message:nil,preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title:"Yes,delete",style: .destructive,handler: { (_) in
            let selectedPodcast = self.podcasts[selectedIndexPath.item]
            self.podcasts.remove(at: selectedIndexPath.item)
            self.collectionView?.deleteItems(at: [selectedIndexPath])
            UserDefaults.standard.deletePodcast(podcast: selectedPodcast)
        }))
        alertController.addAction(UIAlertAction(title:"Cancel",style: .cancel))
        present(alertController,animated:true)
        
    }
    //MARK:- UICollectionView Delegate/Spacing
    override func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int{
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,didSelectItemAt indexPath: IndexPath){
        let episodesController = EpisodesController()
        episodesController.podcast = self.podcasts[indexPath.item]
        navigationController?.pushViewController(episodesController,animated: true )
    }
    override func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritePodcastCell
        cell.podcast = self.podcasts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,layout CollectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.frame.width - 3 * 16) / 2
        return CGSize(width: size,height: size + 40)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout CollectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16,left: 16,bottom: 16,right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView,layout CollectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
