//
//  XcstringsMerge.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/10/24.
//

import Foundation

struct XcstringsMerger {
    /// 合并两个 .xcstrings 文件并输出到目标路径
    static func mergeXcstringsFiles(at firstURL: URL, and secondURL: URL, outputRoot: URL) -> Bool {
        let outputURL = outputRoot.appendingPathComponent("Localizable.xcstrings")
        // 1️⃣ 解析两个文件
        let firstDict = XcstringsFileParser.parseXcstringsFile(at: firstURL)
        let secondDict = XcstringsFileParser.parseXcstringsFile(at: secondURL)
        
        // 2️⃣ 合并逻辑：相同 key → 合并语言，新值覆盖旧值
        var merged = firstDict
        for (key, langs) in secondDict {
            var keyDict = merged[key] ?? [:]
            langs.forEach { (lang, value) in
                keyDict[lang] = value
            }
            merged[key] = keyDict
        }
        
        // 3️⃣ 构建 JSON
        var root: [String: Any] = [
            "sourceLanguage": "en",
            "strings": [:],
            "version" : "1.0"
        ]
        var stringsDict = [String: Any]()
        
        let sortedKeys = merged.keys.sorted(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
        for key in sortedKeys {
            guard let langValues = merged[key] else { continue }
            var localizations = [String: Any]()
            
            for (lang, value) in langValues {
                localizations[lang] = [
                    "stringUnit": [
                        "state": "translated",
                        "value": value
                    ]
                ]
            }
            
            stringsDict[key] = [
                "extractionState": "manual",
                "localizations": localizations
            ]
        }
        
        root["strings"] = stringsDict
        
        // 4️⃣ 写出文件
        do {
            let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: outputURL, options: .atomic)
            print("✅ 合并成功: \(outputURL.path)")
            return true
        } catch {
            print("❌ 写出失败: \(error.localizedDescription)")
            return false
        }
    }
}
