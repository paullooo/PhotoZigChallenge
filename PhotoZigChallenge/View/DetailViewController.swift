//
//  DetailViewController.swift
//  PhotoZigChallenge
//
//  Created by Paulo on 01/01/18.
//  Copyright © 2018 Paulo. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Alamofire


class DetailViewController: UIViewController {
    
    var assetView: AssetView!
    var pageIndex: NSInteger = 0
    
    @IBOutlet weak var downloadProgressIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var subtitileLabe: UILabel!
    @IBOutlet weak var loadingStackView: UIStackView!
    var playerVideo: AVPlayer!
    var playerAudio: AVPlayer!
    var playerItem: AVPlayerItem!
    var downloadInit: Bool?
    
    var playerVideoLayer: AVPlayerLayer!
    
    private var timeObserverToken: Any?
    private var loopObserverToken: Any?
    
    var downloadedVideoURL:URL!
    var downloadedAudioURL:URL!
    
    
    var service: Service!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.service = Service(delegate: self)
        
        downloadedVideoURL = AssetViewModel.getLocalURL(fileName: assetView.videoName)
        downloadedAudioURL = AssetViewModel.getLocalURL(fileName: assetView.audioName)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: downloadedVideoURL.path){
            downloadProgressIndicator.stopAnimating()
            loadingStackView.isHidden = true
            downloadInit = false

            audioPlayerSetup()
            videoPlayerSetup()
            
            playerAudio.play()
            playerVideo.play()
        }else{
            downloadProgressIndicator.hidesWhenStopped = true
            downloadProgressIndicator.startAnimating()
            service.fileDownload(downloadName: assetView.videoName, downloadURL: assetView.videoURL, type: ResponseType.downloadVideo)
            downloadInit = true
        }
    }
    
    func audioPlayerSetup(){
        playerAudio = AVPlayer.init(url: downloadedAudioURL)
        NotificationCenter.default.addObserver(self, selector: #selector(videoStopAtAudioEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerAudio.currentItem)
    }
    
    func videoPlayerSetup(){
        playerVideo = AVPlayer.init(url: downloadedVideoURL!)
        playerVideoLayer = AVPlayerLayer(player: playerVideo)
        playerVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerVideoLayer.frame = view.layer.frame
        playerVideo.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        view.layer.insertSublayer(playerVideoLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerVideo.currentItem)
        addPlayerAudioTimeObserver()
    }
    
    func addPlayerAudioTimeObserver() {
        let interval = CMTime(seconds: 0.1,preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        timeObserverToken = playerAudio.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
            [weak self] time in
            let currentTimeFormated = String(format: "%.1f", time.seconds)
            if let timeFounded = (self?.assetView.subtitles)!.filter({$0.time == currentTimeFormated}).first {
                self?.labelAnimation(subtitle: timeFounded.text)
            }
            print(currentTimeFormated)
        }
    }
    
    func labelAnimation(subtitle:String){
        self.subtitileLabe.text = subtitle
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
            self.subtitileLabe.alpha = 1.0
        }, completion: {
            finished in
            
            if finished {
                
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseIn, animations: {
                    self.subtitileLabe.alpha = 0.0
                }, completion: nil)
            }
        })
    }
    
    func removeObservers() {
        if let timeObserverToken = timeObserverToken {
            playerAudio.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerVideo.currentItem)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerAudio.currentItem)
        
    }
    
    override func viewDidLoad() {
        print(assetView.subtitles)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadingStackView.isHidden = false
        downloadProgressIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(playerVideo != nil||playerAudio != nil){
            playerVideo.pause()
            playerAudio.pause()
            playerVideoLayer.removeFromSuperlayer()
            removeObservers()
            playerVideo.replaceCurrentItem(with: nil)
            playerVideo = nil
            playerAudio.replaceCurrentItem(with: nil)
            playerAudio = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(downloadInit == true){
            service.stopFileDownload()
            
        }
    }
    
    @objc func playerItemReachEnd(notification:NSNotification){
        playerVideo.seek(to: kCMTimeZero)
    }
    
    @objc func videoStopAtAudioEnd(notification:NSNotification){
        playerVideo.pause()
    }
}

extension DetailViewController: ResponseDelegate {
    func success(_ type: ResponseType) {
        switch type{
        case .downloadVideo:
            print("Fim do download de video - \(AssetViewModel.getLocalURL(fileName: assetView.videoName))")
            self.service.fileDownload(downloadName: assetView.audioName, downloadURL: assetView.audioURL, type: ResponseType.downloadAudio)
        case .downloadAudio:
            print("Fim do download de audio - \(AssetViewModel.getLocalURL(fileName: assetView.audioName))")
            print("Inicio do Playback")
            downloadProgressIndicator.stopAnimating()
            loadingStackView.isHidden = true
            audioPlayerSetup()
            videoPlayerSetup()
            
            playerAudio.play()
            playerVideo.play()
        default:
            break
        }
    }
    
    func failure(_ type: ResponseType, error: Error?) {
        downloadProgressIndicator.stopAnimating()
        loadingStackView.isHidden = true
        print("Falha na obtenção dos arquivos ou download cancelado")
    }
}

