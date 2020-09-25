//
//  BWWebCacheManage.swift
//  BWShortVideo
//
//  Created by bairdweng on 2020/9/24.
//

import CommonCrypto
import Foundation
typealias WebCacheClearCompletedBlock = (_ cacheSize: String) -> Void

typealias WebCacheQueryCompletedBlock = (_ data: Any?, _ hasCache: Bool) -> Void

typealias BWWebDownloaderResponseBlock = (_ response: HTTPURLResponse) -> Void

typealias BWWebDownloaderProgressBlock = (_ receivedSize: Int64, _ expectedSize: Int64, _ data: Data?) -> Void

typealias BWWebDownloaderCompletedBlock = (_ data: Data?, _ error: Error?, _ finished: Bool) -> Void

typealias BWWebDownloaderCancelBlock = () -> Void

class BWWebCacheManager: NSObject {
    var memCache: NSCache<NSString, AnyObject>?
    var fileManager = FileManager.default
    var diskCacheDirectoryURL: URL?
    var ioQueue: DispatchQueue?

    private static let instance = { () -> BWWebCacheManager in
        BWWebCacheManager()
    }()

    override private init() {
        super.init()
        memCache = NSCache()
        memCache?.name = "webCache"

        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let path = paths.last
        let diskCachePath = path! + "/webCache"

        var isDirectory: ObjCBool = false
        let isExisted = fileManager.fileExists(atPath: diskCachePath, isDirectory: &isDirectory)
        if !isDirectory.boolValue || !isExisted {
            do {
                try fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Create disk cache file error:" + error.localizedDescription)
            }
        }
        diskCacheDirectoryURL = URL(fileURLWithPath: diskCachePath)
        ioQueue = DispatchQueue(label: "com.start.webcache")
    }

    class func shared() -> BWWebCacheManager {
        return instance
    }

    func queryDataFromMemory(key: String, cacheQueryCompletedBlock: WebCacheQueryCompletedBlock) -> Operation {
        return queryDataFromMemory(key: key, cacheQueryCompletedBlock: cacheQueryCompletedBlock, exten: nil)
    }

    func queryDataFromMemory(key: String, cacheQueryCompletedBlock: WebCacheQueryCompletedBlock, exten: String?) -> Operation {
        let operation = Operation()
        ioQueue?.sync {
            if operation.isCancelled {
                return
            }
            if let data = self.dataFromMemoryCache(key: key) {
                cacheQueryCompletedBlock(data, true)
            } else if let data = self.dataFromDiskCache(key: key, exten: exten) {
                storeDataToMemoryCache(data: data, key: key)
                cacheQueryCompletedBlock(data, true)
            } else {
                cacheQueryCompletedBlock(nil, false)
            }
        }
        return operation
    }

    func queryURLFromDiskMemory(key: String, cacheQueryCompletedBlock: WebCacheQueryCompletedBlock) -> Operation {
        return queryURLFromDiskMemory(key: key, cacheQueryCompletedBlock: cacheQueryCompletedBlock, exten: nil)
    }

    func queryURLFromDiskMemory(key: String, cacheQueryCompletedBlock: WebCacheQueryCompletedBlock, exten: String?) -> Operation {
        let operation = Operation()
        ioQueue?.sync {
            if operation.isCancelled {
                return
            }
            let path = diskCachePathForKey(key: key, exten: exten) ?? ""
            if fileManager.fileExists(atPath: path) {
                cacheQueryCompletedBlock(path, true)
            } else {
                cacheQueryCompletedBlock(path, false)
            }
        }
        return operation
    }

    func dataFromMemoryCache(key: String) -> Data? {
        return memCache?.object(forKey: key as NSString) as? Data
    }

    func dataFromDiskCache(key: String) -> Data? {
        return dataFromDiskCache(key: key, exten: nil)
    }

    func dataFromDiskCache(key: String, exten: String?) -> Data? {
        if let cachePathForKey = diskCachePathForKey(key: key, exten: exten) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: cachePathForKey))
                return data
            } catch {}
        }
        return nil
    }

    func storeDataCache(data: Data?, key: String) {
        ioQueue?.async {
            self.storeDataToMemoryCache(data: data, key: key)
            self.storeDataToDiskCache(data: data, key: key)
        }
    }

    func storeDataToMemoryCache(data: Data?, key: String) {
        memCache?.setObject(data as AnyObject, forKey: key as NSString)
    }

    func storeDataToDiskCache(data: Data?, key: String) {
        storeDataToDiskCache(data: data, key: key, exten: nil)
    }

    func storeDataToDiskCache(data: Data?, key: String, exten: String?) {
        if let diskPath = diskCachePathForKey(key: key, exten: exten) {
            fileManager.createFile(atPath: diskPath, contents: data, attributes: nil)
        }
    }

    func diskCachePathForKey(key: String, exten: String?) -> String? {
        let fileName = md5(key: key)
        var cachePathForKey = diskCacheDirectoryURL?.appendingPathComponent(fileName).path
        if exten != nil {
            cachePathForKey = cachePathForKey! + "." + exten!
        }
        return cachePathForKey
    }

    func diskCachePathForKey(key: String) -> String? {
        return diskCachePathForKey(key: key, exten: nil)
    }

    func clearCache(cacheClearCompletedBlock: @escaping WebCacheClearCompletedBlock) {
        ioQueue?.async {
            self.clearMemoryCache()
            let cacheSize = self.clearDiskCache()
            DispatchQueue.main.async {
                cacheClearCompletedBlock(cacheSize)
            }
        }
    }

    func clearMemoryCache() {
        memCache?.removeAllObjects()
    }

    func clearDiskCache() -> String {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: (diskCacheDirectoryURL?.path)!)
            var folderSize: Float = 0
            for fileName in contents {
                let filePath = (diskCacheDirectoryURL?.path)! + "/" + fileName
                let fileDict = try fileManager.attributesOfItem(atPath: filePath)
                folderSize += fileDict[FileAttributeKey.size] as! Float
                try fileManager.removeItem(atPath: filePath)
            }
            //            return String.format(decimal: folderSize/1024.0/1024.0) ?? "0"
            return ""
        } catch {
            print("clearDiskCache error:" + error.localizedDescription)
        }
        return "0"
    }

    func md5(key: String) -> String {
        let cStrl = key.cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStrl, CC_LONG(strlen(cStrl!)), buffer)
        var md5String = ""
        for idx in 0 ... 15 {
            let obcStrl = String(format: "%02x", buffer[idx])
            md5String.append(obcStrl)
        }
        free(buffer)
        return md5String
    }
}
