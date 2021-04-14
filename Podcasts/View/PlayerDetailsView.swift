//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Vsevolod Shelaiev on 22.10.2020.
//  Copyright © 2020 Vsevolod Shelaiev. All rights reserved.
//

import UIKit
import FeedKit
import Alamofire
import AVKit
import MediaPlayer

class PlayerDetailsView : UIView {
    var episode : Episode! {
        didSet {
            miniPlayerLabel.text = episode.title
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            setupAudioSession()
            setupNowPlayingInfo()
            playEpisode()
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            miniPlayerImage.sd_setImage(with: url)
            episodeImageView.sd_setImage(with: url)
            miniPlayerImage.sd_setImage(with: url) {(image,_,_,_) in
                guard let image = image else {return}
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {(_) ->UIImage in
                    return image
                })
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    
    fileprivate func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    fileprivate func playEpisode() {
        if episode.fileUrl != nil {
            playEpisodeUsingFileURL()
        }else{
            guard let url = URL(string: episode.streamURL) else {return}
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
    }
    fileprivate func playEpisodeUsingFileURL(){
        guard let fileURL = URL(string: episode.fileUrl ?? "") else {return}
        let fileName = fileURL.lastPathComponent
        guard var trueLocation = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask).first else {return}
        trueLocation.appendPathComponent(fileName)
        let playerItem = AVPlayerItem(url: trueLocation)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    var player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayStringTime()
            let durationTime = self?.player.currentItem?.duration
            self?.durationTimeLabel.text = durationTime?.toDisplayStringTime()
            self?.updateCurrentTimeSlider()
        }
    }
    fileprivate func setupLockScreenCurrentTime() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        guard let currentItem = player.currentItem else {return}
        let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1,timescale: 1))
        let percantage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percantage)
    }
    var dismissalPanGesture: UIPanGestureRecognizer!
    fileprivate func setupGestures(){
        addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        dismissalPanGesture = UIPanGestureRecognizer(target: self,action: #selector(handleDismissalPan))
        playerStackView.addGestureRecognizer(dismissalPanGesture)
    }
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer){
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            playerStackView.transform = CGAffineTransform(translationX: 0,y: translation.y)
            DismissBtn.transform = CGAffineTransform(translationX: 0,y: translation.y)
        }else if gesture.state == .ended {
            let translation = gesture.translation(in: superview)
            UIView.animate(withDuration: 0.5,delay: 0,usingSpringWithDamping: 0.7,initialSpringVelocity: 1,options: .curveEaseOut,animations: {
                self.playerStackView.transform = .identity
                self.DismissBtn.transform = .identity
                if translation.y > 60 {
                    UIApplication.mainTabBarController()?.minimizePlayerDetails()
                }
            })
        }
    }
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let errAVAudioSession {
            print("Problem to connect AVAudioSession",errAVAudioSession)
        }
    }
    fileprivate func setupRemoteControll() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playpauseBtn.setImage(#imageLiteral(resourceName: "pause"),for: .normal)
            self.miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "pause"),for: .normal)
            self.setupElapsedTime(playbackRate: 1)
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playpauseBtn.setImage(#imageLiteral(resourceName: "play"),for: .normal)
            self.miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "play"),for: .normal)
            self.setupElapsedTime(playbackRate: 0)
            return .success
        }
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return . success
        }
        commandCenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handleNextTrackLockScreen()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePreviousTrackLockScreen()
            return .success
        }
    }
    var playlistEpisodes = [Episode]()
    fileprivate func handlePreviousTrackLockScreen(){
        if playlistEpisodes.isEmpty {
            return
        }
        let currentEpisodeIndex = playlistEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        guard let index = currentEpisodeIndex else { return }
        let prevEpisode: Episode
        if index == 0 {
            let count = playlistEpisodes.count
            prevEpisode = playlistEpisodes[count - 1]
        } else {
            prevEpisode = playlistEpisodes[index - 1]
        }
        self.episode = prevEpisode
    }
    
    fileprivate func handleNextTrackLockScreen(){
        if playlistEpisodes.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playlistEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpisodeIndex else { return }
        
        let nextEpisode: Episode
        if index == playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        } else {
            nextEpisode = playlistEpisodes[index + 1]
        }
        
        self.episode = nextEpisode
    }
    fileprivate func setupElapsedTime(playbackRate: Float){
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    fileprivate func observeBoundaryTime(){
        let time = CMTimeMake(value: 1,timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("episode started to play")
            self?.enlargeEpisodeImageView()
            self?.setupLockScreenDuration()
        }
    }
    func setupLockScreenDuration(){
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    }
    var panGesture: UIPanGestureRecognizer!
    fileprivate func setupInterruptionObserver(){
        NotificationCenter.default.addObserver(self,selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,object: nil)
    }
    @objc fileprivate func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else {return}
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        if type == AVAudioSession.InterruptionType.began.rawValue {
            print("Interruption began")
            playpauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }else {
            print("Interruption ended")
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                playpauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRemoteControll()
        setupGestures()
        setupInterruptionObserver()
        observePlayerCurrentTime()
        observeBoundaryTime()
    }
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: nil, options: nil)?.first as! PlayerDetailsView
    }
    deinit {
        print("Memory...")
    }
    //MARK:- IB outlets and actions
    //MARK: Mini Player
    @IBOutlet weak var viewForBorders: UIView!{
        didSet{
            viewForBorders.alpha = 0.5
        }
    }
    @IBOutlet weak var miniPlayerForwardBtn: UIButton!{
        didSet{
            miniPlayerForwardBtn.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
    @IBAction func miniPlayerForwardBtnAction(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    @IBOutlet weak var miniPlayerPauseBtn: UIButton! {
        didSet{
            miniPlayerPauseBtn.addTarget(self,action: #selector(handlePlayPause),for: .touchUpInside)
            miniPlayerPauseBtn.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
    
    @IBOutlet weak var miniPlayerLabel: UILabel!
    @IBOutlet weak var miniPlayerImage: UIImageView!
    @IBOutlet weak var miniPlayerView: UIView!

    //MARK: Big Player
    @IBOutlet weak var playerStackView: UIStackView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var DismissBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    @IBAction func volumeChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    @IBAction func fastForwardBtn(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    @IBAction func rewindBtn(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    fileprivate func seekToCurrentTime (delta: Int64) {
        let changeDelta = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), changeDelta)
        player.seek(to: seekTime)
    }
    @IBAction func changeCurrentTimeSlider(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        player.seek(to: seekTime)
        
    }
    @IBOutlet weak var playpauseBtn: UIButton! {
        didSet {
            playpauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playpauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @objc func handlePlayPause() {
        if player.timeControlStatus == .paused {
            player.play()
            miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playpauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            self.setupElapsedTime(playbackRate: 1)
        }else{
            player.pause()
            playpauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView()
            self.setupElapsedTime(playbackRate: 0)
        }
    }
    fileprivate func enlargeEpisodeImageView(){
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    fileprivate func shrinkEpisodeImageView(){
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrunkenTransform
        })
    }
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrunkenTransform
        }
    }
    @IBAction func dismissButton(_ sender: Any) {
        UIApplication.mainTabBarController()?.minimizePlayerDetails()
    }
}
