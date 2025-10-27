//
//  XcstringsFileParser.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/10/24.
//

import Foundation

struct XcstringsFileParser {
    static func parseXcstringsFile(at url: URL) -> [String: [String: String]] {
        guard
            let data = try? Data(contentsOf: url),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let root = jsonObject as? [String: Any],
            let stringsDict = root["strings"] as? [String: Any]
        else {
            print("❌ 解析 .xcstrings 文件失败：文件不是合法 JSON 或缺少 key ‘strings’")
            return [:]
        }

        var result = [String: [String: String]]()

        for (key, entryAny) in stringsDict {
            guard let entry = entryAny as? [String: Any] else { continue }
            let localizations = entry["localizations"] as? [String: Any] ?? [:]

            var langMap = [String: String]()
            for (langCode, locAny) in localizations {
                guard
                    let loc = locAny as? [String: Any],
                    let stringUnit = loc["stringUnit"] as? [String: Any],
                    let value = stringUnit["value"] as? String
                else {
                    continue
                }
                langMap[langCode] = value
            }

            result[key] = langMap
        }

        return result
    }
}
