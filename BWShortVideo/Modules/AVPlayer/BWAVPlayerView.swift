//
//  BWAVPlayerView.swift
//  BWShortVideo
//
//  Created by bairdweng on 2020/9/23.
//

import Async
import AVKit
import MobileCoreServices
import UIKit
class BWAVPlayerView: UIView {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var sourceURL: URL?
    var sourceScheme: String?
    // video downLoad
    var session: URLSession?
    var task: URLSessionDataTask?
    var cancelQueue: DispatchQueue?
    var data: Data?
    var cacheFileKey: String?
    var urlAsset: AVURLAsset?
    var playerItem: AVPlayerItem?
    // cache
    var queryCacheOperation: Operation?

    var response: HTTPURLResponse?
    var pendingRequests = [AVAssetResourceLoadingRequest]()

    var combineOperation: BWWebCombineOperation?
    var playerUrl: String! {
        didSet {
            sourceURL = URL(string: playerUrl)
            cacheFileKey = playerUrl
            queryCacheOperation = BWWebCacheManager.shared().queryURLFromDiskMemory(key: cacheFileKey ?? "", cacheQueryCompletedBlock: { [weak self] _, _ in
                Async.main {
                    // loadCache
                    //                    if hasCache == true {
                    //                        self?.sourceURL = URL.init(fileURLWithPath: path as? String ?? "")
                    //                    }
                    //                    else {
                    //                        self?.sourceURL = self?.sourceURL?.absoluteString.urlScheme(scheme: "streaming")
                    //                    }
                    self?.sourceURL = self?.sourceURL?.absoluteString.urlScheme(scheme: "streaming")
                    if let url = self?.sourceURL {
                        self?.loadData(url: url)
                    }
                }
            }, exten: "mp4")
        }
    }

    func loadData(url: URL) {
        urlAsset = AVURLAsset(url: url, options: nil)
        urlAsset?.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
        if urlAsset != nil {
            playerItem = AVPlayerItem(asset: urlAsset!)
            playerItem?.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
            player = AVPlayer(playerItem: playerItem)
            playerLayer.player = player
        }
    }

    func play() {
        BWAVPlayerManage.shareManage.play(player: player)
    }

    func pause() {
        BWAVPlayerManage.shareManage.pause(player: player)
    }

    func replay() {
        BWAVPlayerManage.shareManage.replay(player: player)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = layer.bounds
        CATransaction.commit()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if playerItem?.status == .readyToPlay {}
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startDownTask(url: URL) {
        if combineOperation != nil {
            combineOperation?.cancel()
        }
        combineOperation = BWWebDownloader.shared().dowload(url: url, response: { [weak self] response in
            self?.data = Data()
            self?.response = response
            self?.processPendingRequests()
        }, progress: { [weak self] _, _, data in
            self?.data?.append(data!)
            self?.processPendingRequests()
        }, completed: { _, error, finished in
            if error == nil, finished == true {}
        }, cancel: {
            print("down load cancel")
        })
    }
}

extension BWAVPlayerView: AVAssetResourceLoaderDelegate {
    func resourceLoader(_: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if task == nil {
            if let url = loadingRequest.request.url?.absoluteString.urlScheme(scheme: sourceScheme ?? "http") {
                startDownTask(url: url)
            }
        }
        pendingRequests.append(loadingRequest)
        return true
    }

    func resourceLoader(_: AVAssetResourceLoader, didCancel _: AVAssetResourceLoadingRequest) {}

    func resourceLoader(_: AVAssetResourceLoader, shouldWaitForResponseTo _: URLAuthenticationChallenge) -> Bool {
        return true
    }
}

extension BWAVPlayerView {
    func processPendingRequests() {
        var requestsCompleted = [AVAssetResourceLoadingRequest]()
        for loadingRequest in pendingRequests {
            let didRespondCompletely = respondWithDataForRequest(loadingRequest: loadingRequest)
            if didRespondCompletely {
                requestsCompleted.append(loadingRequest)
                loadingRequest.finishLoading()
            }
        }
        for completedRequest in requestsCompleted {
            if let index = pendingRequests.firstIndex(of: completedRequest) {
                pendingRequests.remove(at: index)
            }
        }
    }

    func respondWithDataForRequest(loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let mimeType = response?.mimeType ?? ""
        let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        loadingRequest.contentInformationRequest?.contentType = contentType?.takeRetainedValue() as String?
        loadingRequest.contentInformationRequest?.contentLength = (response?.expectedContentLength)!
        var startOffset: Int64 = loadingRequest.dataRequest?.requestedOffset ?? 0
        if loadingRequest.dataRequest?.currentOffset != 0 {
            startOffset = loadingRequest.dataRequest?.currentOffset ?? 0
        }
        if Int64(data?.count ?? 0) < startOffset {
            return false
        }
        let unreadBytes = Int64(data?.count ?? 0) - startOffset
        let numberOfBytesToRespondWidth: Int64 = min(Int64(loadingRequest.dataRequest?.requestedLength ?? 0), unreadBytes)
        if let subdata = (data?.subdata(in: Int(startOffset) ..< Int(startOffset + numberOfBytesToRespondWidth))) {
            loadingRequest.dataRequest?.respond(with: subdata)
            let endOffset: Int64 = startOffset + Int64(loadingRequest.dataRequest?.requestedLength ?? 0)
            return Int64(data?.count ?? 0) >= endOffset
        }
        return false
    }
}
