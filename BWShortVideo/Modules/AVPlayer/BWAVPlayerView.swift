//
//  BWAVPlayerView.swift
//  BWShortVideo
//
//  Created by bairdweng on 2020/9/23.
//

import UIKit
import AVKit
class BWAVPlayerView: UIView {
    
    var player:AVPlayer!
    var playerLayer:AVPlayerLayer!
    var sourceURL:URL?
    
    var playerUrl:String! {
        didSet {
            sourceURL = URL(string: playerUrl)
            guard let url = sourceURL else {
                return
            }
            let asset = AVURLAsset.init(url: url)
            asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
            let playItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playItem)
            self.playerLayer.player = player
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(playerLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = self.layer.bounds
        CATransaction.commit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BWAVPlayerView:AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool {
        return true
    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        
    }
}
