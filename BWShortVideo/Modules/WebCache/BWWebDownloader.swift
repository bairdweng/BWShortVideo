//
//  BWWebDownloader.swift
//  Douyin
//
//  Created by bairdweng on 2020/9/25.
//  .
//

import Foundation

class BWWebDownloader: NSObject {
    var downloadQueue: OperationQueue?

    private static let instance = { () -> BWWebDownloader in
        BWWebDownloader()
    }()

    override private init() {
        super.init()
        downloadQueue = OperationQueue()
        downloadQueue?.name = "com.start.BWWebDownloader"
        downloadQueue?.maxConcurrentOperationCount = 8
    }

    class func shared() -> BWWebDownloader {
        return instance
    }

    func dowload(url: URL, response: @escaping BWWebDownloaderResponseBlock, progress: @escaping BWWebDownloaderProgressBlock, completed: @escaping BWWebDownloaderCompletedBlock, cancel: @escaping BWWebDownloaderCancelBlock) -> BWWebCombineOperation {
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.httpShouldUsePipelining = true
        let key = url.absoluteString
        let operation = BWWebCombineOperation()
        operation.cacheOperation = BWWebCacheManager.shared().queryDataFromMemory(key: key, cacheQueryCompletedBlock: { [weak self] data, hasCache in
            if hasCache {
                completed(data as? Data, nil, true)
            } else {
                let downloadOperation = BWWebDownloadOperation(request: request, response: { res in
                    response(res)
                }, progress: progress, completed: { data, error, finished in
                    if finished, error == nil {
//                        BWWebCacheManager.shared().storeDataCache(data: data, key: key)
                        completed(data, nil, true)
                    } else {
                        completed(data, error, false)
                    }
                }, cancel: {
                    cancel()
                })
                operation.downloadOperation = downloadOperation
                self?.downloadQueue?.addOperation(downloadOperation)
            }
        })
        return operation
    }
}
