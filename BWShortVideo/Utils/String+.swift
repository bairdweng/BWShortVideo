//
//  NSString+.swift
//  Douyin
//
//  Created by Qiao Shi on 2018/8/1.
//  .
//

import CommonCrypto
import Foundation
extension String {
    func substring(location index: Int, length: Int) -> String {
        if count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(self.startIndex, offsetBy: index + length)
            let subString = self[startIndex ..< endIndex]
            return String(subString)
        } else {
            return self
        }
    }

    func substring(range: NSRange) -> String {
        if count > range.location {
            let startIndex = index(self.startIndex, offsetBy: range.location)
            let endIndex = index(self.startIndex, offsetBy: range.location + range.length)
            let subString = self[startIndex ..< endIndex]
            return String(subString)
        } else {
            return self
        }
    }

    func md5() -> String {
        let cStrl = cString(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
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

    func urlScheme(scheme: String) -> URL? {
        if let url = URL(string: self) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = scheme
            return components?.url
        }
        return nil
    }

    static func readJson2DicWithFileName(fileName: String) -> [String: Any] {
        let path = Bundle.main.path(forResource: fileName, ofType: "json") ?? ""
        var dict = [String: Any]()
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        } catch {
            print(error.localizedDescription)
        }
        return dict
    }

    static func format(decimal: Float, _ maximumDigits: Int = 1, _ minimumDigits: Int = 1) -> String? {
        let number = NSNumber(value: decimal)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = maximumDigits // 设置小数点后最多2位
        numberFormatter.minimumFractionDigits = minimumDigits // 设置小数点后最少2位（不足补0）
        return numberFormatter.string(from: number)
    }

    static func formatCount(count: NSInteger) -> String {
        if count < 10000 {
            return String(count)
        } else {
            return (String.format(decimal: Float(count) / Float(10000)) ?? "0") + "w"
        }
    }
}
