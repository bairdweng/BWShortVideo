//
//  BWAVPlayer.swift
//  BWShortVideo
//
//  Created by bairdweng on 2020/9/23.
//

import UIKit
import AVKit
class BWAVPlayerManage: NSObject {
    static let shareManage = BWAVPlayerManage()
    var players:[AVPlayer] = []
    override init() {
        super.init()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch (_) {
            
        }
    }
    func play(player:AVPlayer) {
        players.forEach { (player) in
            player.pause()
        }
        if players.contains(player) == false {
            players.append(player)
        }
        player.play()
    }
}
