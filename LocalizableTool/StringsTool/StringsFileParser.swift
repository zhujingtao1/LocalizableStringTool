//
//  StringsParser.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/15.
//

import Foundation

struct StringsFileParser {
    static func parseStringsFile(at url: URL) -> [String: String] {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return [:] }
        var dict = [String: String]()
        let regex = try! NSRegularExpression(pattern: "\"(.*?)\"\\s*=\\s*\"(.*?)\";", options: [])
        for match in regex.matches(in: content, range: NSRange(location: 0, length: content.utf16.count)) {
            if let keyRange = Range(match.range(at: 1), in: content),
               let valueRange = Range(match.range(at: 2), in: content) {
                dict[String(content[keyRange])] = String(content[valueRange])
            }
        }
        return dict
    }
}
