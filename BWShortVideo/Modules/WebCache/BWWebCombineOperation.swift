//
//  BWWebCombineOperation.swift
//  Douyin
//
//  Created by bairdweng on 2020/9/25.
//  .
//

import Foundation

class BWWebCombineOperation: NSObject {
    // 网络资源下载取消后的回调block
    var cancelBlock: BWWebDownloaderCancelBlock?

    // 查询缓存NSOperation任务
    var cacheOperation: Operation?

    // 下载网络资源任务
    var downloadOperation: BWWebDownloadOperation?

    // 取消查询缓存NSOperation任务和下载资源BWWebDownloadOperation任务
    func cancel() {
        // 取消查询缓存NSOperation任务
        if cacheOperation != nil {
            cacheOperation?.cancel()
            cacheOperation = nil
        }

        // 取消下载资源BWWebDownloadOperation任务
        if downloadOperation != nil {
            downloadOperation?.cancel()
            downloadOperation = nil
        }

        // 任务取消回调
        if cancelBlock != nil {
            cancelBlock?()
            cancelBlock = nil
        }
    }
}
