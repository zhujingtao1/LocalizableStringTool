//
//  XcstringsWriter.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/10/24.
//

import Foundation

struct XcstringsFileWriter {
    static func writeLocalization(to rootURL: URL, newTranslate: [String: [String: String]]) -> Bool {
        // 1️⃣ 读取原有翻译
        var alreadyExistTrans = XcstringsFileParser.parseXcstringsFile(at: rootURL)

        // 2️⃣ 合并新翻译（新值覆盖旧值）
        newTranslate.forEach { (key, langs) in
            var keyDict = alreadyExistTrans[key] ?? [:]
            langs.forEach { (lang, value) in
                keyDict[lang] = value
            }
            alreadyExistTrans[key] = keyDict
        }

        // 3️⃣ 构建 JSON 结构
        var root: [String: Any] = [
            "sourceLanguage": "en",
            "strings": [:],
            "version" : "1.0"
        ]

        var stringsDict = [String: Any]()
        let sortedKeys = alreadyExistTrans.keys.sorted(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })

        for key in sortedKeys {
            guard let langValues = alreadyExistTrans[key] else { continue }

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

        // 4️⃣ 写出 JSON
        do {
            let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: rootURL, options: .atomic)
            print("✅ 写入成功：\(rootURL.path)")
            return true
        } catch {
            print("❌ 写入失败：\(error.localizedDescription)")
            return false
        }
    }
}
